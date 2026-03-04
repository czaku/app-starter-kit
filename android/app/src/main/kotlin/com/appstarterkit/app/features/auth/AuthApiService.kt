package com.appstarterkit.app.features.auth

import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.POST

data class RequestMagicLinkBody(val email: String)
data class VerifyMagicLinkBody(val email: String, val code: String)
data class AuthResponse(val accessToken: String, val refreshToken: String)
data class MessageResponse(val message: String)

interface AuthApiService {
    @POST("auth/magic-link/request")
    suspend fun requestMagicLink(@Body body: RequestMagicLinkBody): MessageResponse

    @POST("auth/magic-link/verify")
    suspend fun verifyMagicLink(@Body body: VerifyMagicLinkBody): AuthResponse

    /** Fire-and-forget session termination. Server invalidates the refresh token. */
    @DELETE("auth/session")
    suspend fun deleteSession(): MessageResponse
}
