### Steps to Create a Chrome PWA Installation Button on a Website

**1. Prepare the PWA**
- Ensure a valid `manifest.json` file is included in your project. It must specify properties like `name`, `short_name`, `start_url`, `icons`, and `display` set to `"standalone"` or `"fullscreen"`[5].
- The site must be served over HTTPS and include a registered and functioning Service Worker[5].

**2. Add Install Button to HTML**
- Add the button HTML to your page:
```html
<button id="install" hidden>Install App</button>
```
- Keep the button hidden initially[7].

**3. Capture `beforeinstallprompt` Event**
- Use JavaScript to listen for the `beforeinstallprompt` event:
```javascript
let installPromptEvent;

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  installPromptEvent = event;
  document.querySelector('#install').removeAttribute('hidden');
});
```
- `preventDefault()` stops the browser’s default install prompt, allowing custom UI[7].

**4. Trigger the Install Prompt**
- Add an event listener to the install button:
```javascript
document.querySelector('#install').addEventListener('click', async () => {
  if (installPromptEvent) {
    installPromptEvent.prompt();
    const { outcome } = await installPromptEvent.userChoice;
    console.log(`User response to the install prompt: ${outcome}`);
    installPromptEvent = null;
    document.querySelector('#install').setAttribute('hidden', '');
  }
});
```
- The `prompt()` method triggers the installation prompt, and `userChoice` provides the user’s decision[7].

**5. Handle Installation Events**
- Optionally, listen for the `appinstalled` event to track successful installations:
```javascript
window.addEventListener('appinstalled', () => {
  console.log('PWA was installed');
});
```
- This event confirms the app's installation on the user's device[7].

**6. Test the PWA**
- Ensure all installability criteria are met by testing in Chrome DevTools (Application > Manifest > Installability)[5].

This setup enables a custom in-app button to prompt users to install the PWA, improving visibility and control over the installation process.