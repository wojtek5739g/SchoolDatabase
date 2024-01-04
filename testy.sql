ALTER SESSION SET NLS_DATE_FORMAT = "DD/MM/YYYY";

-- test procedury zmiana_klasy
exec zmiana_klasy(7, 2);

-- test procedury nowy_dyrektor 
exec nowy_dyrektor (5);

/

-- test procedury nowy_dyrektor (równie¿ test triggera)
ALTER TRIGGER tr_czy_moze_byc_dyrektorem ENABLE;

INSERT INTO Nauczyciele VALUES (25, 'Krzysztof', 'Drzewicki', '12/07/2014');

exec nowy_dyrektor (25);

-- test funkcji ile_lat_pracuje
SELECT ile_lat_pracuje(20) from dual;

-- test funkcji srednia_z_przedmiotu

SELECT srednia_z_przedmiotu(1, 2) from dual;

-- czy uczen, ktoremu zostala przypisana ocena do przedmiotu, chodzi na ten przedmiot (test_triggera)
ALTER TRIGGER tr_czy_uczen_chodzi_na_przedmiot ENABLE;

UPDATE Oceny_uczniow
SET ocena_id = 4, konkretny_przedmiot_id = 2 
WHERE uczen_id = 1;

-- zapytanie, zwracajace ilu uczniow chodzi do danej klasy
SELECT klasa_id, COUNT(uczen_id)
FROM uczniowie
GROUP BY klasa_id
ORDER BY klasa_id asc;

-- zapytanie zwracajace id ucznia i ocene z danego przedmiotu z nazwa
SELECT o.uczen_id, o.ocena_id, p.nazwa FROM OCENY_UCZNIOW o JOIN KONKRETNE_PRZEDMIOTY k ON (o.konkretny_przedmiot_id = k.konkretny_przedmiot_id) JOIN PRZEDMIOTY p ON (k.przedmiot_id = p.przedmiot_id)
ORDER BY o.uczen_id;

-- zapytanie wyswietlajace nauczyciela z odpowiadajaca mu nazwa przedmiotu
BEGIN
    FOR r_nau IN (SELECT n.imie as imie, n.nazwisko as nazwisko,
         p.nazwa as nazwa
         FROM nauczyciele n JOIN
         konkretne_przedmioty k USING (nauczyciel_id) JOIN
         przedmioty p USING (przedmiot_id))
    LOOP
         dbms_output.put_line('Dane nauczyciela: ' || r_nau.imie || ' ' || r_nau.nazwisko
         || ' ' || r_nau.nazwa);
    END LOOP;
END;

-- wyswietlenie daty rozpoczecia i daty zakonczenia dla nauczyciela, jezeli jest dyrektorem
SELECT n.nauczyciel_id, n.imie, n.nazwisko, n.data_dolaczenia, d.dyrektor_id, d.data_rozpoczecia, d.data_zakonczenia FROM nauczyciele n LEFT JOIN dyrektorowie d ON (n.nauczyciel_id = d.nauczyciel_id);

