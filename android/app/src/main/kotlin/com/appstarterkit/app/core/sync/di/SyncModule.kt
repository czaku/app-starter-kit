package com.appstarterkit.app.core.sync.di

import android.content.Context
import com.appstarterkit.app.core.network.ApiClient
import com.appstarterkit.app.core.network.NetworkMonitor
import com.appstarterkit.app.core.sync.SyncApiService
import com.appstarterkit.app.core.sync.SyncEngine
import com.appstarterkit.app.core.sync.SyncMetrics
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object SyncModule {

    @Provides
    @Singleton
    fun provideSyncMetrics(@ApplicationContext context: Context): SyncMetrics =
        SyncMetrics(context)

    @Provides
    @Singleton
    fun provideSyncEngine(
        @ApplicationContext context: Context,
        network: NetworkMonitor,
        metrics: SyncMetrics,
    ): SyncEngine = SyncEngine(context, network, metrics)

    @Provides
    @Singleton
    fun provideSyncApiService(apiClient: ApiClient): SyncApiService =
        apiClient.create()
}
