import { Injectable, Logger } from '@nestjs/common';

// TODO: Install firebase-admin and configure with service account key
// import * as admin from 'firebase-admin';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  async sendToDevice(
    fcmToken: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    this.logger.log(
      `[FCM] TODO: send "${title}" to token ${fcmToken.slice(0, 8)}...`,
    );
    // TODO: admin.messaging().send({ token: fcmToken, notification: { title, body }, data })
  }

  async sendToTopic(topic: string, title: string, body: string): Promise<void> {
    this.logger.log(`[FCM] TODO: send "${title}" to topic ${topic}`);
  }
}
