# PowerShell ISE Font Smoothing Addon

For all the perfectionists out there:

Before:
![before][]

After:
![after][]

**If you noticed the difference, — this addon is for you.**

[before]: assets/Before.png
[after]: assets/After.png

### Installation

1. Install from PowerShell Gallery:

```powershell
Install-Module ISEFontSmoothing
```

2. Add module import to your ISE profile:

```powershell
"Import-Module ISEFontSmoothing" | Add-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1"
```

3. Relaunch ISE.

### Known Issues

Because profiles get loaded after entire Host UI has already been initialized, font smoothing machinery provided by this addon does not come into effect **until** you open new editor tab (Ctrl+N) or new PowerShell tab (Ctrl+T).
This behavior is by design.
