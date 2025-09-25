# Data Update Implementation Summary

## Overview
This document outlines the implementation of a comprehensive data update system that ensures all data sources (API, SharedPreferences, and local database) are synchronized when farmer profile information is updated.

## Current Implementation Analysis

### Profile View Screen (`lib/screens/common/profile_view_screen.dart`)
The profile view screen uses multiple data sources for displaying farmer information:

1. **SharedPreferences**: Accessed via `_getProfileData()` method
   - Retrieves user data stored as JSON string under 'user_data' key
   - Used as primary data source for display

2. **BlocBuilder with FarmerBloc**: Listens to farmer state changes
   - Uses `SingleFarmerLoaded` state to get farmer data
   - Falls back to SharedPreferences data if state data is not available

3. **Data Priority**: 
   - SharedPreferences data takes precedence over bloc state data
   - Falls back to empty strings if neither source has data

## New Implementation

### 1. Enhanced Farmer Events (`lib/blocs/farmer/farmer_event.dart`)
Added two new events to handle comprehensive data updates:

```dart
class UpdateFarmerProfile extends FarmerEvent {
  final Farmer farmer;
  UpdateFarmerProfile(this.farmer);
}

class UpdateAllDataSources extends FarmerEvent {
  final Farmer farmer;
  UpdateAllDataSources(this.farmer);
}
```

### 2. Enhanced Farmer Bloc (`lib/blocs/farmer/farmer_bloc.dart`)
Added event handlers for the new events:

#### `UpdateFarmerProfile` Event:
- Updates API via `DatabaseService.updateFarmerInApi()`
- Updates SharedPreferences via `SharedPrefsService.saveFarmerData()`
- Emits `SingleFarmerLoaded` state on success

#### `UpdateAllDataSources` Event:
- **Step 1**: Updates API via `DatabaseService.updateFarmerInApi()`
- **Step 2**: Updates SharedPreferences via `SharedPrefsService.saveFarmerData()`
- **Step 3**: Updates local database via `DatabaseService.updateFarmer()`
- **Step 4**: Emits `SingleFarmerLoaded` state with updated farmer data

### 3. Enhanced Database Service (`lib/services/database_service.dart`)
Added new method for API updates:

```dart
static Future<bool> updateFarmerInApi(Farmer farmer) async {
  // Performs PATCH request to update farmer data in the backend API
  // Returns true on success, false on failure
}
```

### 4. Enhanced Edit Farmer Details Screen (`lib/screens/farmer/edit_farmer_details.dart`)

#### Key Changes:
1. **Added BlocListener**: Wraps the entire screen to listen for farmer state changes
2. **Automated Navigation**: Automatically navigates to profile screen on successful update
3. **Error Handling**: Shows error messages via SnackBar on failure
4. **Simplified Update Logic**: Replaced manual API calls with `UpdateAllDataSources` event

#### BlocListener Implementation:
```dart
BlocListener<FarmerBloc, FarmerState>(
  listener: (context, state) {
    if (state is SingleFarmerLoaded) {
      // Handle successful update
      // Show success message
      // Navigate to profile screen
    } else if (state is FarmerError) {
      // Handle error
      // Show error message
    }
  },
  child: Scaffold(...),
)
```

## Data Flow

### When Update Button is Clicked:
1. **Form Validation**: Validates all input fields
2. **Farmer Object Creation**: Creates updated Farmer object with new data
3. **Bloc Event Dispatch**: Dispatches `UpdateAllDataSources(farmer)` event
4. **Bloc Processing**:
   - Updates API (backend database)
   - Updates SharedPreferences (local storage)
   - Updates local SQLite database
5. **State Emission**: Emits `SingleFarmerLoaded` state with updated data
6. **UI Response**: BlocListener responds to state change
7. **User Feedback**: Shows success message and navigates to profile screen

### Profile Screen Refresh:
1. **Data Sources**: Profile screen pulls from updated SharedPreferences
2. **Bloc State**: Also reflects updated farmer data
3. **UI Update**: All sections show updated information immediately

## Benefits of This Implementation

1. **Data Consistency**: All data sources are updated in a single operation
2. **Error Handling**: Comprehensive error handling with user feedback
3. **State Management**: Proper BLoC pattern implementation
4. **Automatic Refresh**: Profile screen automatically shows updated data
5. **Maintainability**: Centralized update logic in the bloc
6. **User Experience**: Smooth navigation with loading states and feedback

## Usage Example

When a user updates their profile information and clicks the update button:

```dart
// In _saveFarmer() method
final farmer = Farmer(
  id: widget.farmer?.id ?? _generateId(),
  name: _nameController.text.trim(),
  // ... other fields
  updatedAt: DateTime.now(),
);

// Dispatch the update event
BlocProvider.of<FarmerBloc>(context).add(UpdateAllDataSources(farmer));
```

The system automatically handles:
- API update
- SharedPreferences update  
- Local database update
- State management
- UI feedback
- Navigation

This ensures that when the user returns to the profile screen, all sections display the most current information from all data sources.
