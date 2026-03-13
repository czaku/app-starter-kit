package com.appstarterkit.app.core.sync

sealed class SyncState {
    object Idle : SyncState()
    object Syncing : SyncState()
    data class Error(val message: String) : SyncState()
    object Offline : SyncState()
}
