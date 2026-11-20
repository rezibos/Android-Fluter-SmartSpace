package com.example.witdget

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "nekouse/daily_energy"
    private val preferencesName = "nekouse_energy"

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
    }
}
