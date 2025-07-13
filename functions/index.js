const admin = require("firebase-admin");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function notificarAdministradoresYGimnasio(
  gimnasioId,
  usuarioData,
  usuarioId,
  nuevoEstado
) {
  try {
    const adminsSnapshot = await db
      .collection("gimnasios")
      .doc(gimnasioId)
      .collection("usuarios")
      .where("tipo", "in", ["Administrador", "Dueño"])
      .get();

    if (adminsSnapshot.empty) {
      console.log(
        `ℹ️ No hay administradores/dueños para el gimnasio ${gimnasioId}`
      );
      return;
    }

    // Filtrar tokens válidos y mantener referencia a cada admin para guardar notificación en subcolección
    const adminsConToken = adminsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        token: doc.data().token
      }))
      .filter(
        (admin) => typeof admin.token === "string" && admin.token.length > 10
      );

    if (adminsConToken.length === 0) {
      console.log(
        `ℹ️ No hay administradores/dueños con token registrado en este gimnasio`
      );
      return;
    }

    const tokens = adminsConToken.map((a) => a.token);

    const payloadNotification = {
      title: `Cambio de estado usuario ${usuarioId}`,
      body: `El usuario ha cambiado a estado ${nuevoEstado}`,
      sound: "default"
    };

    const payloadData = {
      gimnasioId,
      usuarioId,
      nuevoEstado,
      tipoNotificacion: "estadoUsuario"
    };

    const response = await admin.messaging().sendMulticast({
      tokens,
      notification: payloadNotification,
      data: payloadData
    });

    console.log(
      `📲 Notificaciones enviadas: ${response.successCount} exitosas, ${response.failureCount} fallidas.`
    );

    response.responses.forEach((resp, idx) => {
      if (resp.error) {
        console.error(`❌ Error enviando a token ${tokens[idx]}:`, resp.error);
      }
    });

    const notificacionData = {
      titulo: payloadNotification.title,
      mensaje: payloadNotification.body,
      fechaEnvio: admin.firestore.FieldValue.serverTimestamp(),
      tipo: "estadoUsuario",
      tokensDestino: tokens,
      exitosos: response.successCount,
      fallidos: response.failureCount,
      detalles: response.responses.map((resp, idx) => ({
        token: tokens[idx],
        success: resp.success,
        error: resp.error ? resp.error.message : null
      }))
    };

    // Guardar en colección general de notificaciones del gimnasio
    await db
      .collection("gimnasios")
      .doc(gimnasioId)
      .collection("notificaciones")
      .add(notificacionData);

    // Guardar en la subcolección 'notificaciones' de cada usuario admin/dueño
    const batch = db.batch();

    adminsConToken.forEach((adminUser, index) => {
      const userNotificacionRef = db
        .collection("gimnasios")
        .doc(gimnasioId)
        .collection("usuarios")
        .doc(adminUser.id)
        .collection("notificaciones")
        .doc();

      batch.set(userNotificacionRef, {
        ...notificacionData,
        fechaEnvio: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    await batch.commit();

    console.log(
      `📝 Notificación registrada en subcolecciones de administradores/dueños para gimnasio ${gimnasioId}`
    );
  } catch (error) {
    console.error(`❌ Error notificando administradores/gimnasio:`, error);
  }
}

exports.actualizarEstadosUsuarios = onSchedule(
  {
    schedule: "* * * * *",
    timeZone: "America/Caracas"
  },
  async (event) => {
    console.log("🟢 Iniciando tarea programada de actualización de usuarios");

    try {
      // Aquí tu lógica real para actualizar estados, por ejemplo:
      // await tuFuncionDeActualizarEstados();

      // Enviar notificación siempre, para pruebas
      const message = {
        notification: {
          title: "Notificación de prueba",
          body: "Este es un mensaje de prueba enviado a todos los usuarios."
        },
        topic: "general" // asegúrate que la app esté suscrita a este topic
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Notificación general enviada:", response);

      return null;
    } catch (error) {
      console.error("❌ Error en la tarea programada:", error);
      return null;
    }
  }
);
