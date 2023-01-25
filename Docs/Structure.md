#  Structure

## Project Structure

* Main application
  * The main application code is located in the `BookmarkCompanion` project. This is the main app that is bundled, signed and shipped to the AppStore.
* Share extension
  * The extension for sharing URLs with the application from the iOS Share Sheet
* Shared code
  * All shared code (Helpers, Components, ...) are located in the `Shared` framework.
* Integrations
  * Integrations are placed in a framework named after the service they integration. (e.g. `Linkding`)
  * All integration specific code (like dtos, sync client, UI parts) are placed only in the Framework codebase. Nothing specific shuold be placed in the `BookmarkCompanion` or `Shared` codebases.
