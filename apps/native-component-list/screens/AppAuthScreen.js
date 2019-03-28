import { AppAuth } from 'expo';
import React from 'react';
import { AsyncStorage, Button, StyleSheet, Text, View } from 'react-native';

const GUID = '603386649315-vp4revvrcgrcjme51ebuhbkbspl048l9';
const config = {
  issuer: 'https://accounts.google.com',
  clientId: `${GUID}.apps.googleusercontent.com`,
  scopes: ['openid', 'profile'],
};

const StorageKey = '@Storage:Key';

async function signInAsync() {
  const authState = await AppAuth.authAsync(config);
  await cacheAuthAsync(authState);
  console.log('signInAsync', authState);
  return authState;
}

async function refreshAuthAsync({ refreshToken }) {
  const authState = await AppAuth.refreshAsync(config, refreshToken);
  console.log('refresh', authState);
  await cacheAuthAsync(authState);
  return authState;
}

async function getCachedAuthAsync() {
  const value = await AsyncStorage.getItem(StorageKey);
  const authState = JSON.parse(value);
  console.log('getCachedAuthAsync', authState);
  if (authState) {
    if (checkIfTokenExpired(authState)) {
      return refreshAuthAsync(authState);
    } else {
      return authState;
    }
  }
}

function cacheAuthAsync(authState) {
  return AsyncStorage.setItem(StorageKey, JSON.stringify(authState));
}

function checkIfTokenExpired({ accessTokenExpirationDate }) {
  return new Date(accessTokenExpirationDate) < new Date();
}

async function signOutAsync({ accessToken }) {
  try {
    await AppAuth.revokeAsync(config, {
      token: accessToken,
      isClientIdProvided: true,
    });
    await AsyncStorage.removeItem(StorageKey);
    return null;
  } catch (error) {
    alert('Failed to revoke token: ' + error.message);
  }
}

export default class AuthSessionScreen extends React.Component {
  static navigationOptions = {
    title: 'AuthSession',
  };

  state = {};

  componentDidMount() {
    this._getAuthAsync();
  }

  _getAuthAsync = async () => {
    try {
      const authState = await getCachedAuthAsync();
      this.setState({ authState });
    } catch ({ message }) {
      alert(message);
    }
  };

  _toggleAuthAsync = async () => {
    try {
      if (this.state.authState) {
        await signOutAsync(this.state.authState);
        this.setState({ authState: null });
      } else {
        const authState = await signInAsync();
        this.setState({ authState });
      }
    } catch ({ message }) {
      alert(message);
    }
  };

  get hasAuth() {
    return this.state.authState;
  }

  render() {
    const title = this.hasAuth ? 'Sign out' : 'Sign in';
    return (
      <View style={styles.container}>
        <Button title={title} onPress={this._toggleAuthAsync} />
        {this.hasAuth ? (
          <Text style={styles.text}>
            Result: {JSON.stringify(this.state.authState).slice(0, 50)}
          </Text>
        ) : null}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    marginVertical: 15,
    marginHorizontal: 10,
  },
  faintText: {
    color: '#888',
    marginHorizontal: 30,
  },
  oopsTitle: {
    fontSize: 25,
    marginBottom: 5,
    textAlign: 'center',
  },
  oopsText: {
    textAlign: 'center',
    marginTop: 10,
    marginHorizontal: 30,
  },
});
