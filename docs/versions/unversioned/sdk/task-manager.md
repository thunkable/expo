---
title: TaskManager
---

An API that allows to manage tasks, especially these running while your app is in the background.
Some features of this module are used by other modules under the hood. Here is a list of modules using TaskManager:

- [Location](./location.md)
- [BackgroundFetch](./background-fetch.md)

*Despite this module is an universal module, it is **not compatible** with vanilla React Native applications yet.*

## Configuration

On iOS, each background feature requires a special key in `UIBackgroundModes` array in your `Info.plist` file. In standalone apps this array is empty by default, so in order to use background features you will need to add appropriate keys to your `app.json` configuration.
Example of `app.json` that enables background location and background fetch:

```json
{
  "expo": {
    ...
    "ios": {
      ...
      "infoPlist": {
        ...
        "UIBackgroundModes": [
          "location",
          "fetch"
        ]
      }
    }
  }
}
```

## Methods

### `TaskManager.defineTask(taskName, task)`

Defines task function.
It must be called in the global scope of your JavaScript bundle. In particular, it **cannot** be called in any of React lifecycle methods like `componentDidMount`.
This limitation is due to the fact that when the application is launched in the background, we need to spin up your JavaScript app, run your task and then shut down — no views are mounted in this scenario.

#### Arguments

-   **taskName (_string_)** -- Name of the task.
-   **task (_function_)** -- A function that will be invoked when the task with given **taskName** is executed.

### `TaskManager.isTaskRegisteredAsync(taskName)`

Determine whether the task is registered. Registered tasks are stored in a persistent storage and preserved between sessions.

#### Arguments

-   **taskName (_string_)** -- Name of the task.

#### Returns

Returns a promise resolving to a boolean value whether or not the task with given name is already registered.

### `TaskManager.getTaskOptionsAsync(taskName)`

Retrieves options associated with the task, that were passed to the function registering the task (eg. `Location.startLocationUpdatesAsync`).

#### Arguments

-   **taskName (_string_)** -- Name of the task.

#### Returns

Returns a promise resolving to the options object that was passed while registering task with given name or `null` if task couldn't be found.

### `TaskManager.getRegisteredTasksAsync()`

Provides information about tasks registered in the app.

#### Returns

Returns a promise resolving to an array of tasks registered in the app.
Example:

```javascript
[
  {
    taskName: 'location-updates-task-name',
    taskType: 'location',
    options: {
      accuracy: Location.Accuracy.High,
      showsBackgroundLocationIndicator: false,
    },
  },
  {
    taskName: 'geofencing-task-name',
    taskType: 'geofencing',
    options: {
      regions: [...],
    },
  },
]
```

### `TaskManager.unregisterTaskAsync(taskName)`

Unregisters task from the app, so the app will not be receiving updates for that task anymore.
*It is recommended to use methods specialized by modules that registered the task, eg. [Location.stopLocationUpdatesAsync](./location.md#expolocationstoplocationupdatesasynctaskname).*

#### Arguments

-   **taskName (_string_)** -- Name of the task to unregister.

#### Returns

Returns a promise resolving as soon as the task is unregistered.

### `TaskManager.unregisterAllTasksAsync()`

Unregisters all tasks registered for the running app.

### Returns

Returns a promise that resolves as soon as all tasks are completely unregistered.

## Examples

```javascript
import React from 'react';
import { Location, TaskManager } from 'expo';
import { Text, TouchableOpacity } from 'react-native';

const LOCATION_TASK_NAME = 'background-location-task';

export default class Component extends React.Component {
  onPress = async () => {
    await Location.startLocationUpdatesAsync(LOCATION_TASK_NAME, {
      accuracy: Location.Accuracy.Balanced,
    });
  };

  render() {
    return (
      <TouchableOpacity onPress={this.onPress}>
        <Text>Enable background location</Text>
      </TouchableOpacity>
    );
  }
}

TaskManager.defineTask(LOCATION_TASK_NAME, ({ data, error }) => {
  if (error) {
    // Error occurred - check `error.message` for more details.
    return;
  }
  if (data) {
    const { locations } = data;
    // do something with the locations captured in the background
  }
});
```
