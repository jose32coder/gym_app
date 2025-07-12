const admin = require("firebase-admin");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();
const db = admin.firestore();

exports.actualizarEstadosUsuarios = onSchedule(
  {
    schedule: "* * * * *",
    timeZone: "America/Caracas"
  },
  async (event) => {
    console.info("🟢 Iniciando tarea programada de actualización de usuarios");

    try {
      const gimnasiosSnapshot = await db.collection("gimnasios").get();

      if (gimnasiosSnapshot.empty) {
        console.warn("⚠️ No hay gimnasios registrados.");
        return null;
      }

      for (const gimnasioDoc of gimnasiosSnapshot.docs) {
        const gimnasioId = gimnasioDoc.id;
        const gimnasioData = gimnasioDoc.data();

        console.info(`➡️ Procesando gimnasio: ${gimnasioId}`);

        const usuariosSnapshot = await db
          .collection(`gimnasios/${gimnasioId}/usuarios`)
          .where("estado", "in", ["activo", "pendiente"])
          .get();

        if (usuariosSnapshot.empty) {
          console.info("   ⚠️ No hay usuarios activos o pendientes.");
          continue;
        }

        for (const usuarioDoc of usuariosSnapshot.docs) {
          const usuarioData = usuarioDoc.data();
          const usuarioId = usuarioDoc.id;

          if (
            !usuarioData.fechaCorte ||
            typeof usuarioData.fechaCorte.toDate !== "function"
          ) {
            console.warn(
              `   ⚠️ Usuario ${usuarioId} sin fecha de corte válida. Se omite.`
            );
            continue;
          }

          const fechaCorte = usuarioData.fechaCorte.toDate();
          const ahora = new Date();

          if (ahora >= fechaCorte) {
            // Cambiar a inactivo
            await db
              .doc(`gimnasios/${gimnasioId}/usuarios/${usuarioId}`)
              .update({ estado: "inactivo" });

            console.info(`   🔴 Usuario ${usuarioId} cambiado a INACTIVO`);

            // Enviar notificación push al administrador si tiene token
            if (gimnasioData.token) {
              const payload = {
                notification: {
                  title: "Usuario inactivado",
                  body: `El usuario ${
                    usuarioData.nombre || usuarioId
                  } ha sido inactivado por vencimiento de membresía.`,
                  sound: "default"
                },
                data: {
                  gimnasioId: gimnasioId,
                  usuarioId: usuarioId
                }
              };

              await admin
                .messaging()
                .sendToDevice(gimnasioData.token, payload)
                .then((response) => {
                  console.info(
                    `   📲 Notificación enviada a administrador del gimnasio ${gimnasioId}`
                  );
                })
                .catch((error) => {
                  console.error(
                    `   ❌ Error al enviar notificación push:`,
                    error
                  );
                });
            } else {
              console.info(
                `   ℹ️ Gimnasio ${gimnasioId} sin token de notificación.`
              );
            }
          } else {
            // Verificar días restantes
            const diffMs = fechaCorte - ahora;
            const diffDias = diffMs / (1000 * 60 * 60 * 24);

            if (diffDias < 5) {
              await db
                .doc(`gimnasios/${gimnasioId}/usuarios/${usuarioId}`)
                .update({ estado: "pendiente" });
              console.info(
                `   🟡 Usuario ${usuarioId} cambiado a PENDIENTE (${diffDias.toFixed(
                  2
                )} días restantes)`
              );
            } else {
              console.info(
                `   🟢 Usuario ${usuarioId} sigue ACTIVO (${diffDias.toFixed(
                  2
                )} días restantes)`
              );
            }
          }
        }

        console.info(`➡️ Finalizado procesamiento de gimnasio: ${gimnasioId}`);
      }

      console.info("✅ Tarea programada completada.");
      return null;
    } catch (error) {
      console.error("❌ Error en la tarea programada:", error);
      return null;
    }
  }
);
