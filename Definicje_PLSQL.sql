-- procedura, ktora zmienia przypisana uczniowi klase i przepisuje jego oceny
CREATE OR REPLACE PROCEDURE zmiana_klasy(ucz_id NUMBER, nowa_kl_id NUMBER)
AS
    stara_klasa    Klasy.klasa_id%type;
    stary_rok         Klasy.rok%type;
    nowy_rok       Klasy.rok%type;
    nowy_przedm    Konkretne_przedmioty.konkretny_przedmiot_id%type;
    
BEGIN
    SELECT klasa_id INTO stara_klasa FROM Uczniowie WHERE uczen_id = ucz_id;
    SELECT rok INTO stary_rok FROM Klasy WHERE klasa_id = stara_klasa;
    SELECT rok INTO nowy_rok FROM Klasy WHERE klasa_id = nowa_kl_id;
    IF stara_klasa = nowa_kl_id THEN
        raise_application_error(-20010, 'Proba przepisania ucznia do tej samej klasy');
    ELSIF  stary_rok != nowy_rok THEN
        raise_application_error(-20011, 'Proba przepisania ucznia do klasy na innym roku');
    END IF;
    
    FOR prz in (SELECT konkretny_przedmiot_id as st_kon_przedmiot, przedmiot_id as przedmiot
                        FROM Konkretne_przedmioty WHERE klasa_id = stara_klasa)
    LOOP
        SELECT konkretny_przedmiot_id INTO nowy_przedm FROM Konkretne_przedmioty
            WHERE przedmiot_id = prz.przedmiot AND klasa_id = nowa_kl_id;
            
        UPDATE Oceny_uczniow SET konkretny_przedmiot_id = nowy_przedm 
            WHERE konkretny_przedmiot_id = prz.st_kon_przedmiot AND uczen_id = ucz_id;
    END LOOP;
    UPDATE Uczniowie SET klasa_id = nowa_kl_id WHERE uczen_id = ucz_id;
END;
/
-- procedura, ktora dodaje nowego dyrektora
CREATE OR REPLACE PROCEDURE nowy_dyrektor(n_id NUMBER)
AS
    poprzedni       Dyrektorowie%rowtype;
    data_rozp_poprz Dyrektorowie.data_rozpoczecia%type;
    curr_date       Dyrektorowie.data_rozpoczecia%type;
    nowy_id         Dyrektorowie.dyrektor_id%type;
BEGIN
    SELECT MAX(data_rozpoczecia) INTO data_rozp_poprz FROM Dyrektorowie;
    SELECT * INTO poprzedni FROM Dyrektorowie WHERE data_rozpoczecia = data_rozp_poprz;
    IF poprzedni.nauczyciel_id = n_id THEN 
        raise_application_error(-20003, 'Proba przypisania obecnego dyrektora jako nowego');
    END IF;
    SELECT SYSDATE INTO curr_date FROM dual;
    UPDATE Dyrektorowie SET data_zakonczenia = curr_date WHERE dyrektor_id = poprzedni.dyrektor_id;
    nowy_id := poprzedni.dyrektor_id + 1;
    INSERT INTO Dyrektorowie VALUES (nowy_id, curr_date, null, n_id);
END;
/
-- funkcja ktora bierze id nauczyciela i zwraca liczbe pelnych lat (365 dni), ktore dany nauczyciel juz przepracowal w tej szkole
CREATE OR REPLACE FUNCTION ile_lat_pracuje(n_id NUMBER)
RETURN NUMBER
AS
    lata NUMBER;
    dni  NUMBER;
BEGIN
    SELECT FLOOR(SYSDATE - data_dolaczenia) INTO dni FROM Nauczyciele WHERE nauczyciel_id = n_id;
    lata := FLOOR (dni / 365);
    RETURN lata;
END;
/
-- funkcja ktora zwraca srednia ucznia z danego przedmiotu
CREATE OR REPLACE FUNCTION srednia_z_przedmiotu(ucz_id NUMBER, prz_id NUMBER)
RETURN NUMBER
AS
    klasa           Klasy.klasa_id%type;
    konkr_przedmiot Konkretne_przedmioty.konkretny_przedmiot_id%type;
    licznik         NUMBER(3)       := 0;
    srednia         NUMBER(6, 2)    := 0;
    
    
BEGIN
    
    SELECT klasa_id INTO klasa FROM Uczniowie
        WHERE uczen_id = ucz_id;
    SELECT konkretny_przedmiot_id INTO konkr_przedmiot FROM Konkretne_przedmioty 
        WHERE klasa_id = klasa AND przedmiot_id = prz_id;
    FOR oce in (SELECT oc.liczba as ocena FROM Oceny_uczniow  JOIN Oceny oc USING (ocena_id) 
                    WHERE konkretny_przedmiot_id = konkr_przedmiot AND uczen_id = ucz_id)
    LOOP
        licznik := licznik + 1;
        srednia := srednia + oce.ocena;
    END LOOP;
    
    IF licznik > 0 THEN
        srednia := ROUND(srednia/licznik, 2);
        RETURN srednia;
    ELSE 
        RETURN 0;
    END IF;
END;
/
-- trigger, ktory sprawdza czy dany nauczyciel moze byc dyrektorem (czy ma co najmniej 15 lat stazu)
CREATE OR REPLACE TRIGGER tr_czy_moze_byc_dyrektorem
BEFORE INSERT OR UPDATE ON Dyrektorowie FOR EACH ROW
DECLARE
    lata NUMBER;
BEGIN
    lata := ile_lat_pracuje(:new.nauczyciel_id);
    IF lata < 15 THEN
        raise_application_error(-20001, 'Dyrektor musi miec co najmniej 15 lat stazu');
    END IF;
END;
/
-- trigger, ktory sprawdza, czy uczen, ktoremu zostala przypisana ocena do przedmiotu, chodzi na ten przedmiot
CREATE OR REPLACE TRIGGER tr_czy_uczen_chodzi_na_przedmiot
BEFORE INSERT OR UPDATE ON Oceny_uczniow FOR EACH ROW
DECLARE
    kl_id    NUMBER;
    czy_jest NUMBER;
BEGIN
    SELECT klasa_id INTO kl_id FROM Konkretne_przedmioty WHERE konkretny_przedmiot_id = :new.konkretny_przedmiot_id;
    SELECT COUNT(*) INTO czy_jest FROM Uczniowie WHERE uczen_id = :new.uczen_id AND klasa_id = kl_id;
    IF czy_jest < 1 THEN
        raise_application_error(-20002, 'Uczniowi zostala przypisana ocena z przedmiotu, na ktory nie chodzi');
    END IF;
END;
/


