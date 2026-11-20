package com.example.witdget

import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseNetworkException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "nekouse/daily_energy"
    private val preferencesName = "nekouse_energy"
    private val settingsChannelName = "nekouse/app_settings"
    private val authChannelName = "nekouse/firebase_auth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val preferences = getSharedPreferences(preferencesName, MODE_PRIVATE)
                when (call.method) {
                    "loadDailyEnergy" -> result.success(
                        mapOf(
                            "date" to preferences.getString("date", null),
                            "kwh" to (
                                preferences.getString("kwh", null)?.toDoubleOrNull() ?: 0.0
                            ),
                        ),
                    )

                    "saveDailyEnergy" -> {
                        val date = call.argument<String>("date")
                        val kwh = call.argument<Double>("kwh")
                        if (date == null || kwh == null) {
                            result.error("INVALID_ENERGY", "Date and kWh are required", null)
                        } else {
                            preferences.edit()
                                .putString("date", date)
                                .putString("kwh", kwh.toString())
                                .apply()
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannelName)
            .setMethodCallHandler { call, result ->
                val preferences = getSharedPreferences("nekouse_settings", MODE_PRIVATE)
                when (call.method) {
                    "loadHost" -> result.success(preferences.getString("esp32_host", null))
                    "saveHost" -> {
                        val host = call.argument<String>("host")
                        if (host == null) {
                            result.error("INVALID_HOST", "Host is required", null)
                        } else {
                            preferences.edit().putString("esp32_host", host).apply()
                            result.success(null)
                        }
                    }
                    "clearHost" -> {
                        preferences.edit().remove("esp32_host").apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, authChannelName)
            .setMethodCallHandler { call, result ->
                val configured = FirebaseApp.initializeApp(this) != null
                when (call.method) {
                    "isConfigured" -> result.success(configured)
                    "isSignedIn" -> result.success(
                        configured && FirebaseAuth.getInstance().currentUser != null,
                    )
                    "signIn" -> {
                        if (!configured) {
                            result.error(
                                "FIREBASE_NOT_CONFIGURED",
                                "Firebase configuration is missing",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        val email = call.argument<String>("email")
                        val password = call.argument<String>("password")
                        if (email == null || password == null) {
                            result.error("INVALID_CREDENTIAL", "Credentials are required", null)
                            return@setMethodCallHandler
                        }
                        FirebaseAuth.getInstance()
                            .signInWithEmailAndPassword(email, password)
                            .addOnCompleteListener { task ->
                                if (task.isSuccessful) {
                                    result.success(null)
                                } else {
                                    val code = when (val exception = task.exception) {
                                        is FirebaseAuthException -> exception.errorCode
                                        is FirebaseNetworkException -> "NETWORK_ERROR"
                                        else -> "INVALID_CREDENTIAL"
                                    }
                                    result.error(code, "Authentication failed", null)
                                }
                            }
                    }
                    "signOut" -> {
                        if (configured) FirebaseAuth.getInstance().signOut()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
