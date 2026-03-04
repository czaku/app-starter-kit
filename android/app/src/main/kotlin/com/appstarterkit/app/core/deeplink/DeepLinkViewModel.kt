package com.appstarterkit.app.core.deeplink

import android.net.Uri
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

/**
 * Activity-scoped ViewModel that bridges incoming deep-link intents to the
 * Compose navigation tree.
 *
 * [MainActivity] writes OTP codes extracted from incoming URIs here.
 * [CodeEntryScreen] reads [pendingCode] and auto-populates the code field.
 */
@HiltViewModel
class DeepLinkViewModel @Inject constructor() : ViewModel() {

    private val _pendingCode = MutableStateFlow<String?>(null)
    val pendingCode: StateFlow<String?> = _pendingCode.asStateFlow()

    /**
     * Called from [MainActivity.onCreate] and [MainActivity.onNewIntent].
     *
     * Supported URI patterns:
     *  - https://yourapp.com/auth/verify?code=XXXXXXXX
     *  - appstarterkit://auth/verify?code=XXXXXXXX
     */
    fun handleUri(uri: Uri?) {
        if (uri == null) return
        val code = uri.getQueryParameter("code") ?: return
        if (code.isNotBlank()) {
            _pendingCode.value = code
        }
    }

    /** Must be called after the code has been consumed to avoid re-applying it. */
    fun consumeCode() {
        _pendingCode.value = null
    }
}
