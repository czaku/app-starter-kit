# Sync HTTP Contract

This document defines the HTTP API shape that the starter kit sync engine expects.
Each app's backend implements these endpoints for its own data collections.

---

## POST /sync/push

Push local changes to the server.

**Request**
```json
{
  "changes": [
    {
      "id": "abc123",
      "collection": "todos",
      "action": "update",
      "payload": { "title": "Buy milk", "done": true },
      "updatedAt": "2026-03-13T10:00:00Z"
    }
  ],
  "deviceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response 200**
```json
{
  "applied": [
    { "id": "abc123", "collection": "todos", "success": true }
  ],
  "conflicts": [
    {
      "id": "def456",
      "collection": "todos",
      "clientVersion": { "title": "Old title" },
      "serverVersion": { "title": "Server title" },
      "serverUpdatedAt": "2026-03-13T09:55:00Z"
    }
  ],
  "errors": [],
  "timestamp": "2026-03-13T10:00:01Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `applied` | array | Changes the server accepted and persisted |
| `conflicts` | array | Changes rejected due to concurrent server edits |
| `errors` | array | Changes rejected for other reasons (validation, etc.) |
| `timestamp` | ISO8601 string | Server time at response — use as next `since` baseline |

---

## GET /sync/pull

Pull server changes since a given timestamp.

**Query parameters**

| Parameter | Required | Example | Description |
|-----------|----------|---------|-------------|
| `since` | no | `2026-03-13T09:00:00Z` | ISO8601 timestamp. Omit for full sync. |
| `collections` | no | `todos,notes` | Comma-separated list. Omit for all collections. |

**Response 200**
```json
{
  "items": [
    {
      "id": "abc123",
      "collection": "todos",
      "action": "update",
      "payload": { "title": "Buy milk", "done": true },
      "updatedAt": "2026-03-13T10:00:00Z"
    }
  ],
  "hasMore": false,
  "nextSyncAt": "2026-03-13T10:00:01Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `items` | array | Changes to apply locally |
| `hasMore` | bool | `true` if results were paginated — client should re-poll immediately |
| `nextSyncAt` | ISO8601 string | Suggested timestamp for the next `since` parameter |

---

## SyncChange shape

Used in both push and pull payloads.

| Field | Type | Values |
|-------|------|--------|
| `id` | string | Record ID |
| `collection` | string | Collection/table name (app-defined) |
| `action` | string | `"create"` \| `"update"` \| `"delete"` |
| `payload` | object | Record fields. Empty `{}` for `delete` actions. |
| `updatedAt` | ISO8601 string | Client-reported last-modified time |

---

## Authentication

All sync endpoints require a valid JWT in the `Authorization: Bearer <token>` header.
The starter kit's `APIClient` (iOS) / `ApiClient` (Android) handle token refresh automatically.

---

## Implementing for a new app

1. Add `/sync/push` and `/sync/pull` routes to your NestJS backend
2. Scope queries to `req.user.id` — never return another user's data
3. Implement optimistic locking: compare `updatedAt` before accepting a push; return a conflict if the server version is newer
4. Return `hasMore: true` and paginate if a single pull would exceed ~500 items
