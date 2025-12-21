# 🔧 How to Fix Firestore Permission Error

## The Problem
You're seeing: **"Permission denied. Please check Firestore security rules."**

This happens because Firestore blocks all access by default for security. You need to update the rules to allow authenticated users to write their own data.

## ✅ Step-by-Step Solution

### Step 1: Open Firebase Console
1. Go to: **https://console.firebase.google.com/**
2. Sign in with your Google account
3. **Select your FitWell project** from the list

### Step 2: Navigate to Firestore Rules
1. In the left sidebar, click **"Firestore Database"**
2. Click on the **"Rules"** tab at the top (next to "Data", "Indexes", "Usage")

### Step 3: Replace the Rules
You'll see something like this (default rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**DELETE ALL OF THAT** and replace it with:

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

### Step 4: Publish the Rules
1. Click the **"Publish"** button (usually blue, at the top right)
2. Wait for confirmation that rules are published (usually takes a few seconds)

### Step 5: Test
1. Go back to your app
2. Try signing up again
3. The error should be gone! ✅

## 🎯 What These Rules Do

- ✅ **Authenticated users** can create/read/update/delete their own user document
- ✅ **Authenticated users** can manage their own meals, water, medicines, workouts, and progress
- ❌ **Unauthenticated users** cannot access any data
- ❌ **Users cannot** access other users' data (security!)

## ⚠️ Troubleshooting

### If you still get errors:
1. **Make sure you clicked "Publish"** - rules don't apply until published
2. **Wait 10-20 seconds** after publishing for rules to propagate
3. **Check the rules syntax** - make sure there are no typos
4. **Verify you're signed in** - the rules require authentication

### If you can't find Firestore Database:
- Make sure you've enabled Firestore in your Firebase project
- Go to Firebase Console → Your Project → Build → Firestore Database
- If it's not enabled, click "Create database" and choose "Start in test mode" (then update rules immediately!)

## 📸 Visual Guide

The Rules tab should look like a code editor. You'll see:
- A text area with the rules code
- A "Publish" button at the top
- A "Validate" button to check syntax

---

**After updating the rules, your signup should work perfectly!** 🎉

