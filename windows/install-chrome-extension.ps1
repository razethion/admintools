# Uses a registry key to tell chrome to install an extension. Useful with intune deployments.
reg add HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist /v 1 /t REG_SZ /d ppnbnpeolgkicgegkbkbjmhlideopiji /f
Start-Sleep -Seconds 10
