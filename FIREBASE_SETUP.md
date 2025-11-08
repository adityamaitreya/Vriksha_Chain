# Firebase Database Setup Guide

## Setting up Firebase Realtime Database

### Step 1: Enable Firebase Realtime Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **vriksha-chain**
3. In the left sidebar, click on **"Build"** → **"Realtime Database"**
4. Click **"Create Database"**
5. Choose a location (preferably closest to your users)
6. Start in **Test mode** (for development)
   - Security rules will be set to allow read/write for 30 days
   - For production, you'll need to configure proper security rules

### Step 2: Get Database URL

After creating the database, you'll see a URL like:
```
https://vriksha-chain-default-rtdb.firebaseio.com
```

This URL is already configured in `src/lib/firebase.ts` as the `databaseURL`.

### Step 3: Configure Security Rules (Important for Production)

For development/testing, use these rules:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

For production, use authenticated rules:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "products": {
      ".indexOn": ["status", "category"]
    },
    "batches": {
      ".indexOn": ["status", "productName"]
    }
  }
}
```

### Step 4: Initialize Sample Data

1. Run the development server:
   ```bash
   npm run dev
   ```

2. Navigate to `/initialize-data` route (or use the button in your app)
3. Click "Initialize Sample Data" button
4. This will populate your database with sample products, batches, and statistics

### Step 5: Verify Data in Firebase Console

1. Go back to Firebase Console
2. Navigate to Realtime Database
3. You should see three main nodes:
   - `products/` - Contains all product data
   - `batches/` - Contains batch tracking information
   - `stats/` - Contains dashboard statistics

## Database Structure

```
vriksha-chain-db/
├── products/
│   ├── {productId}/
│   │   ├── name: string
│   │   ├── category: string
│   │   ├── origin: string
│   │   ├── batch: string
│   │   ├── quantity: string
│   │   ├── status: "Available" | "Low Stock" | "Out of Stock"
│   │   ├── quality: "Premium" | "Standard"
│   │   └── lastUpdated: string (ISO date)
│   └── ...
├── batches/
│   ├── {batchId}/
│   │   ├── batchNumber: string
│   │   ├── productName: string
│   │   ├── quantity: string
│   │   ├── origin: string
│   │   ├── harvestDate: string
│   │   ├── status: string
│   │   ├── quality: string
│   │   ├── currentLocation: string
│   │   └── lastUpdated: string
│   └── ...
└── stats/
    ├── activeBatches: number
    ├── supplyPartners: number
    ├── qualityScore: number
    └── traceabilityRate: number
```

## Usage in Components

### Reading Data

```typescript
import { useProducts, useBatches, useStats } from "@/hooks/useFirebaseData";

function MyComponent() {
  const { products, loading, error } = useProducts();
  const { batches, loading: batchesLoading } = useBatches();
  const { stats } = useStats();

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return <div>{/* Use products data */}</div>;
}
```

### Writing Data

```typescript
import { addProduct, updateProduct, deleteProduct } from "@/hooks/useFirebaseData";

// Add a new product
await addProduct({
  name: "New Product",
  category: "Category",
  origin: "Location",
  batch: "BATCH-001",
  quantity: "100kg",
  status: "Available",
  quality: "Premium",
  lastUpdated: new Date().toISOString()
});

// Update a product
await updateProduct("productId", {
  quantity: "150kg",
  lastUpdated: new Date().toISOString()
});

// Delete a product
await deleteProduct("productId");
```

## Real-time Updates

The app automatically subscribes to real-time updates. When data changes in Firebase:
- The UI updates automatically
- No manual refresh needed
- All connected clients see changes instantly

## Troubleshooting

### "Permission Denied" Error
- Check your Firebase security rules
- Make sure database URL is correct
- For development, use test mode rules

### Data Not Showing
- Verify Firebase initialization completed
- Check browser console for errors
- Ensure database URL in `firebase.ts` is correct
- Try re-initializing sample data

### Connection Issues
- Check internet connectivity
- Verify Firebase project is active
- Check Firebase Console for service status

## Next Steps

1. ✅ Enable Firebase Realtime Database
2. ✅ Initialize sample data using `/initialize-data` page
3. ✅ View real-time data on Dashboard
4. ✅ Test CRUD operations in Products page
5. 🔒 Configure proper security rules for production
6. 🚀 Deploy your application

## Resources

- [Firebase Realtime Database Documentation](https://firebase.google.com/docs/database)
- [Security Rules Guide](https://firebase.google.com/docs/database/security)
- [Best Practices](https://firebase.google.com/docs/database/usage/best-practices)
