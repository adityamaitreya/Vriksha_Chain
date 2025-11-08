## Firebase Authentication Setup

1) Create a Firebase project and enable Email/Password and Google providers in Authentication.

2) Create a Web App in Firebase console and copy the config values. Create a `.env` in the project root using this template (Vite requires `VITE_` prefix):

```
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=1234567890
VITE_FIREBASE_APP_ID=1:1234567890:web:abcdef012345
```

3) Install dependencies and start the dev server:

```
npm install
npm run dev
```

4) Relevant files:
- `src/lib/firebase.ts` initializes Firebase and exports `auth` and `googleProvider`.
- `src/contexts/AuthContext.tsx` implements auth state, email/password, Google sign-in, and logout.
- `src/components/LoginForm.tsx` uses the context to sign in and offers a Google button.

Notes:
- For Google on localhost, add `http://localhost:5173` to Authorized domains.
- Add the same env vars in your hosting provider (e.g., Vercel) and redeploy.
