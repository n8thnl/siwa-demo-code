# SIWA Demo iOS Project

This project contains a simple sign in workflow that allows one of the simplest sign-in-with-apple (SIWA) integrations. 

## How to Deploy
1. Pull this code into XCode
2. Add the Sign In With Apple Capability to your project
3. After deploying the CDK stack, grab the Api Gateway baseUrl and populate the `baseUrl` variable in the file `Utils/Api.swift`

**Note**: To reset the SIWA process, its best to *Erase all Content and Settings* in the simulator, and remove this app from your iCloud Sign In With Apple apps (Settings -> iCloud -> Passwords and Security -> Sign In With Apple)