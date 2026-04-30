// Enumerations for the Chat System matching the backend contract.
// These enums map directly to the integer values defined in the
// Integration Guide and are used across DTOs, models, and the Cubit.

/// Type of message content.
///
/// Only [text] and [image] are supported in this integration phase.
enum MessageType {
  text,       // 0
  image,      // 1
  file,       // 2
  voiceRecord // 3
}

/// Filter for fetching chat rooms.
enum ChatRoomFilter {
  all,    // 0
  unread  // 1
}

/// Delivery status of a message (received via SignalR events).
enum MessageDeliveryStatus {
  sent,      // 0
  delivered, // 1
  read       // 2
}

/// Type of message update (received via `MessageUpdated` SignalR event).
enum MessageUpdateType {
  read,      // 0 — Messages in a room were marked as read
  deleted,   // 1 — A specific message was deleted
  delivered  // 2 — Message delivery confirmed
}

/// Status of a message in the local offline outbox queue.
enum OutboxMessageStatus {
  pending, // Waiting to be sent
  sending, // Currently being sent
  failed   // Failed to send (user can retry)
}
