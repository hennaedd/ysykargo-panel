const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Admin SDK başlatılmadıysa başlat
if (admin.apps.length === 0) {
    admin.initializeApp();
}

/**
 * Realtime Database'deki /notifications/{notificationId} yoluna yeni kayıt girildiğinde tetiklenir.
 */
exports.sendPushNotification = functions.database.ref('/notifications/{notificationId}')
    .onCreate(async (snapshot, context) => {
        const notificationData = snapshot.val();

        // Veri yoksa işlem yapma
        if (!notificationData) return null;

        console.log('Yeni bildirim tetiklendi:', notificationData.title);

        const targetType = notificationData.targetType || 'Tümü'; // 'Tümü', 'Müşteri', 'Kurye'

        try {
            // 1. Firestore'dan Tokenları Çek
            // Koleksiyon adının 'userToken' olduğundan emin olun.
            const tokensSnapshot = await admin.firestore().collection('userToken').get();

            if (tokensSnapshot.empty) {
                console.log('Hiçbir token bulunamadı.');
                return null;
            }

            // 2. Kullanıcı Bilgilerini Realtime DB'den Çek (Filtreleme için)
            const usersSnapshot = await admin.database().ref('users').once('value');
            const users = usersSnapshot.val() || {};

            const tokensToSend = [];

            // 3. Tokenları ve Kullanıcıları Eşleştir
            tokensSnapshot.forEach(doc => {
                const userId = doc.id;
                const tokenData = doc.data();
                const token = tokenData.token;

                if (token) {
                    const user = users[userId];
                    // Kullanıcı veritabanında yoksa veya banlıysa atla
                    if (!user || user.account_status === 'banned') return;

                    const userType = user.user_type; // Örn: 'Kurye', 'Müşteri'

                    // Hedef kitle kontrolü
                    let shouldSend = false;
                    if (targetType === 'Tümü') {
                        shouldSend = true;
                    } else if (targetType === 'Kurye' && userType === 'Kurye') {
                        shouldSend = true;
                    } else if (targetType === 'Müşteri' && userType !== 'Kurye') {
                        shouldSend = true;
                    }

                    if (shouldSend) {
                        tokensToSend.push(token);
                    }
                }
            });

            if (tokensToSend.length > 0) {
                // Bildirim İçeriği (Multicast için)
                const message = {
                    notification: {
                        title: notificationData.title || 'Yeni Bildirim',
                        body: notificationData.body || ''
                    },
                    data: {
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        notification_id: context.params.notificationId
                    },
                    tokens: tokensToSend
                };

                // Gönderim Yap (Multicast - HTTP v1)
                const response = await admin.messaging().sendEachForMulticast(message);
                console.log(`Başarılı: ${response.successCount}, Hatalı: ${response.failureCount}`);

                if (response.failureCount > 0) {
                    const failedTokens = [];
                    response.responses.forEach((resp, idx) => {
                        if (!resp.success) {
                            failedTokens.push(tokensToSend[idx]);
                        }
                    });
                    console.log('Hatalı Tokenlar:', failedTokens);
                }
            } else {
                console.log('Filtreleme kriterlerine uyan aktif kullanıcı/token bulunamadı.');
            }

        } catch (error) {
            console.error('Bildirim gönderilirken hata oluştu:', error);
        }

        return null;
    });
