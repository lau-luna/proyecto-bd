package database;

import java.sql.Connection;
import java.sql.DriverManager;

/** Singleton para la conexion a la base de datos */
public class DBConnection {
  // Datos de conexión
  private static String driver = "org.postgresql.Driver";
  private static String url = "jdbc:postgresql://localhost:5432/facu";
  private static String username = "lau";
  private static String password = "lau1545";
  // Una única conexión para todo el programa
  private Connection connection;

  private static DBConnection singleton;

  private DBConnection() {
    try {
      // Cargar el driver
      Class.forName(driver);

      // Conectarse a PostgreSQL
      connection = DriverManager.getConnection(url, username, password);

      System.out.println("Conexión exitosa");

    } catch (Exception e) {
      // Tira excepción si el driver no se encuentra o la conexión falla
      System.out.println(e.getMessage());
      e.printStackTrace();
    }
  }

  public static Connection getConnection() {
    if (singleton == null) {
      singleton = new DBConnection();
    }
    return singleton.connection;
  }
}
