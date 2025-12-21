# Firestore Security Rules Setup

## The Error
You're seeing: `[cloud_firestore/permission-denied] Missing or insufficient permissions.`

This happens because Firestore security rules are blocking writes. By default, Firestore denies all access for security.

## Solution: Update Firestore Security Rules

### Option 1: Using Firebase Console (Recommended for Web)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab at the top

3. **Replace the existing rules** with the rules from `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - users can read/write their own document
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // Meals subcollection
      match /meals/{mealId} {
        allow read, write: if isOwner(userId);
      }
      
      // Water subcollection
      match /water/{waterId} {
        allow read, write: if isOwner(userId);
      }
      
      // Medicines subcollection
      match /medicines/{medicineId} {
        allow read, write: if isOwner(userId);
      }
      
      // Workouts subcollection
      match /workouts/{workoutId} {
        allow read, write: if isOwner(userId);
      }
      
      // Progress subcollection
      match /progress/{progressId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

4. **Click "Publish"** to save the rules

### Option 2: Using Firebase CLI (If you have it installed)

```bash
firebase deploy --only firestore:rules
```

## What These Rules Do

- ✅ **Authenticated users** can create/read/update/delete their own user document
- ✅ **Authenticated users** can manage their own meals, water, medicines, workouts, and progress data
- ❌ **Unauthenticated users** cannot access any data
- ❌ **Users cannot** access other users' data

## Security Notes

- These rules ensure users can only access their own data
- All operations require authentication
- The `userId` in the path must match the authenticated user's ID

## Testing

After updating the rules:
1. Try signing up again
2. The error should be resolved
3. You should be able to create your account and access the dashboard

