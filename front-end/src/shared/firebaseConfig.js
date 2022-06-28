import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getAuth } from "firebase/auth";

// import { initializeAppCheck, ReCaptchaEnterpriseProvider } from "firebase/app-check";

const firebaseConfig = JSON.parse(process.env.VUE_APP_FIREBASE_CONFIG)

const firebaseApp = initializeApp(firebaseConfig);

// initializeAppCheck(firebaseApp, {
//     provider: new ReCaptchaEnterpriseProvider(process.env.VUE_APP_RECAPTCHA_KEY),
//     isTokenAutoRefreshEnabled: true // Set to true to allow auto-refresh.
//   })

const db = getFirestore(firebaseApp);
const storage = getStorage(firebaseApp);
const auth = getAuth(firebaseApp);

export { db, storage, auth };