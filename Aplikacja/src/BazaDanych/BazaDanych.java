package BazaDanych;
sadfas
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.HeadlessException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

public class BazaDanych extends JFrame implements ActionListener {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private JTextField textField;
	private JButton jButton;
	private JTextArea jTextArea;
	private JScrollPane scroll;
	private static String username;
	private static String password;
	private static Connection conn = null;

	public BazaDanych() throws HeadlessException, SQLException {
		
		textField = new JTextField("Wpisz kwerend�");
		jButton = new JButton("Wykonaj kwerend�");
		jTextArea = new JTextArea("");
		
		scroll = new JScrollPane(jTextArea, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		this.setSize(500, 500);
		this.setDefaultCloseOperation(DISPOSE_ON_CLOSE);
		this.setLayout(new BorderLayout());
		JPanel miniframe = new JPanel();
		miniframe.setLayout(new FlowLayout());
		miniframe.add(textField);
		miniframe.add(jButton);
		this.add(miniframe, BorderLayout.PAGE_START);
		this.add(scroll, BorderLayout.CENTER);
		jButton.addActionListener(this);
		
		
	}
	
	public static boolean isDbConnected() throws SQLException {
		
	    final String CHECK_SQL_QUERY = "SELECT * from uczniowie";
	    boolean isConnected = false;
	    try {
	    	conn = DriverManager.getConnection("jdbc:oracle:thin:@//ora4.ii.pw.edu.pl:1521/pdb1.ii.pw.edu.pl", username, password);
//	        final PreparedStatement statement = conn.prepareStatement(CHECK_SQL_QUERY);
	        isConnected = true;
	    } catch (SQLException | NullPointerException e) {
	    	JOptionPane.showMessageDialog(null, "The username or password is wrong. Try again", "Error", JOptionPane.PLAIN_MESSAGE);
	    }
	    return isConnected;
	}
	
	public static void main(String[] args) throws SQLException {
			
//			BazaDanych frame = new BazaDanych();
//			username = JOptionPane.showInputDialog("What is your username?: ");
//			password = JOptionPane.showInputDialog("What is your password?: ");
//			if (password != null || username != null)
//			{
//				while (!isDbConnected())
//				{
//					username = JOptionPane.showInputDialog("What is your username?: ");
//					password = JOptionPane.showInputDialog("What is your password?: ");
//					if (password == null || username == null)
//					{
//						System.exit(0);
//					}
//				}
//			}
//			else
//			{
//				System.exit(0);
//			}
//		
//		frame.setVisible(true);	
		
    }
	
	@Override
	public void actionPerformed(ActionEvent e) {
		
		try {
			jTextArea.setText("");
			
			conn = DriverManager.getConnection("jdbc:oracle:thin:@//ora4.ii.pw.edu.pl:1521/pdb1.ii.pw.edu.pl", username, password);
			
			String kwerenda = textField.getText();
//			char sign = stat.charAt(0);
//			int number = Character.getNumericValue(sign);
//			System.out.println(number);

//			Scanner st = new Scanner(stat);
//			while(!st.hasNextDouble())
//			{
//				st.next();
//			}
//			Double number = st.nextDouble();
			
			Statement statement = conn.createStatement();
			
			
			statement.execute(kwerenda);
			
			
			ResultSet rs = statement.getResultSet();
			
			ResultSetMetaData md  = rs.getMetaData();
					

			for (int ii = 1; ii <= md.getColumnCount(); ii++){
				jTextArea.append(md.getColumnName(ii)+ " | ");						
				
			}
			jTextArea.append("\n");
			
			while (rs.next()) {
				for (int ii = 1; ii <= md.getColumnCount(); ii++){
					jTextArea.append( rs.getObject(ii) + " | ");							
				}
				jTextArea.append("\n");
			}
			javax.swing.SwingUtilities.invokeLater(new Runnable() {
				   public void run() { 
				       scroll.getVerticalScrollBar().setValue(0);
				   }
				});
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} finally {
			if (conn!= null){
				try {
					conn.close();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		}
		
	}

}
