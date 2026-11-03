package proveedores;

import database.DBConnection;
//
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

public class ProveedoresApp {
  static Connection connection = DBConnection.getConnection();

  static Scanner teclado = new Scanner(System.in);

  public static void main(String[] args) throws Exception {
    int opcion;

    do {
      //System.out.println(connection.getMetaData().getURL());

      System.out.println("\n--- MENU PROVEEDORES ---");
      System.out.println("1. Insertar proveedor");
      System.out.println("2. Eliminar proveedor");
      System.out.println("3. Listar proveedores");
      System.out.println("0. Salir");
      System.out.print("Seleccione una opción: ");

      opcion = teclado.nextInt();

      switch (opcion) {
        case 1:
          insertarProveedor();
          break;

        case 2:
          eliminarProveedor();
          break;

        case 3:
          listarProveedores();
          break;

        case 0:
          System.out.println("Fin del programa");
          break;

        default:
          System.out.println("Opción incorrecta");
      }

    } while (opcion != 0);

    // Cerrar conexión al salir
    connection.close();
    teclado.close();
  }

  public static void insertarProveedor() {

    try {
      // Solicitar los datos del proveedor
      System.out.print("Ingrese CUIT: ");
      long cuit = teclado.nextLong();
      teclado.nextLine();

      System.out.print("Ingrese razon social: ");
      String razonSocial = teclado.nextLine();

      System.out.print("Ingrese direccion: ");
      String direccion = teclado.nextLine();

      System.out.print("Ingrese telefono fijo: ");
      String telFijo = teclado.nextLine();

      // Sentencia SQL
      String sql =
          "INSERT INTO proyecto.proveedor "
              + "(cuit, razon_social, direccion, tel_fijo) "
              + "VALUES (?, ?, ?, ?)";

      // Preparar la sentencia
      PreparedStatement ps = connection.prepareStatement(sql);

      // Asignar los valores
      ps.setLong(1, cuit);
      ps.setString(2, razonSocial);
      ps.setString(3, direccion);
      ps.setString(4, telFijo);

      // Ejecutar la inserción
      int filas = ps.executeUpdate();

      if (filas > 0) {
        System.out.println("Proveedor insertado correctamente");
      }

      ps.close();

    } catch (SQLException e) {
      System.out.println("Error al insertar proveedor: " + e.getMessage());
    }
  }

  public static void eliminarProveedor() {
    try {
      // Solicitar el CUIT del proveedor
      System.out.print("Ingrese el CUIT del proveedor que desea eliminar: ");
      long cuit = teclado.nextLong();
      teclado.nextLine();

      // Sentencia SQL
      String sql = "DELETE FROM proyecto.proveedor WHERE cuit = ?";

      // Preparar la sentencia
      PreparedStatement ps = connection.prepareStatement(sql);

      // Asignar el CUIT
      ps.setLong(1, cuit);

      // Ejecutar la eliminación
      int filas = ps.executeUpdate();

      if (filas > 0) {
        System.out.println("Proveedor eliminado correctamente");
      } else {
        System.out.println("No existe un proveedor con ese CUIT");
      }

      ps.close();

    } catch (SQLException e) {
      System.out.println("Error al eliminar proveedor: " + e.getMessage());
    }
  }

  public static void listarProveedores() {
    try {
      // Crear el Statement
      Statement st = connection.createStatement();

      // Ejecutar la consulta
      String sql = "SELECT * FROM proyecto.proveedor";
      ResultSet rs = st.executeQuery(sql);

      // Recorrer los resultados
      while (rs.next()) {

        System.out.println("----------------------");
        System.out.println("CUIT: " + rs.getLong("cuit"));
        System.out.println("Razon social: " + rs.getString("razon_social"));
        System.out.println("Direccion: " + rs.getString("direccion"));
        System.out.println("Telefono fijo: " + rs.getString("tel_fijo"));

      }

      rs.close();
      st.close();

    } catch (SQLException e) {
      System.out.println("Error: " + e.getMessage());
    }
  }
}

