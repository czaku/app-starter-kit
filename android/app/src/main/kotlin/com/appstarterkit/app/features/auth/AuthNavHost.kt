package com.appstarterkit.app.features.auth

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.appstarterkit.app.core.deeplink.DeepLinkViewModel
import com.appstarterkit.app.features.home.HomeScreen
import kotlinx.coroutines.launch

@Composable
fun AuthNavHost(
    viewModel: AuthViewModel = hiltViewModel(),
    deepLinkViewModel: DeepLinkViewModel = hiltViewModel(),
) {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "welcome") {
        composable("welcome") {
            WelcomeScreen(onGetStarted = { navController.navigate("enter-email") })
        }
        composable("enter-email") {
            EmailInputScreen(
                viewModel = viewModel,
                onCodeSent = { email -> navController.navigate("enter-code/$email") },
            )
        }
        composable("enter-code/{email}") { backStackEntry ->
            val email = backStackEntry.arguments?.getString("email") ?: ""

            // Observe any OTP code delivered via deep link and auto-populate it.
            val pendingCode by deepLinkViewModel.pendingCode.collectAsState()
            LaunchedEffect(pendingCode) {
                val code = pendingCode ?: return@LaunchedEffect
                if (code.isNotBlank()) {
                    viewModel.verifyCode(email, code)
                    deepLinkViewModel.consumeCode()
                }
            }

            CodeEntryScreen(
                viewModel = viewModel,
                email = email,
                onAuthenticated = { navController.navigate("home") { popUpTo(0) } },
            )
        }
        composable("home") {
            HomeScreen(
                onLogout = {
                    // Delegate to AuthViewModel which calls AuthRepository.logout()
                    // and then resets navigation to the auth root.
                    viewModel.logout {
                        navController.navigate("welcome") {
                            popUpTo(0) { inclusive = true }
                        }
                    }
                },
            )
        }
    }
}
