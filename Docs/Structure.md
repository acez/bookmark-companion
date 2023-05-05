#  Structure

## Project Structure

* Main application
  * The main application code is located in the `BookmarkCompanion` project. This is the main app that is bundled, signed and shipped to the AppStore.
* Share extension
  * The extension for sharing URLs with the application from the iOS Share Sheet
* CompanionApplication Framework
  * All shared code (Helpers, Components, ...) are located in the `Shared` framework.
  * Integrations
    * All integrations are placed within the integration folder with all their code (like dtos, sync client, UI parts, coredata model)
