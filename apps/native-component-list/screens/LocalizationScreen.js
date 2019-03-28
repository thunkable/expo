import { Localization } from 'expo-localization';
import i18n from 'i18n-js';
import chunk from 'lodash/chunk';
import React from 'react';
import { Picker, ScrollView, StyleSheet, Text, View } from 'react-native';

import HeadingText from '../components/HeadingText';
import ListButton from '../components/ListButton';
import MonoText from '../components/MonoText';

i18n.fallbacks = true;
i18n.locale = Localization.locale;
i18n.translations = {
  en: {
    phrase: 'Hello my friend',
    default: 'English language only',
  },
  ru: {
    phrase: 'Привет мой друг',
  },
};

export default class LocalizationScreen extends React.Component {
  static navigationOptions = {
    title: 'Localization',
  };
  state = {
    currentLocale: Localization.locale,
    preferredLocales: Localization.locales,
    isoCurrencyCodes: Localization.isoCurrencyCodes,
  };

  queryPreferredLocales = async () => {
    const preferredLocales = Localization.locales;
    const currentLocale = Localization.locale;
    this.setState({ preferredLocales, currentLocale });
  };

  queryCurrencyCodes = async () => {
    if (this.state.isoCurrencyCodes.length === 0) {
      const isoCurrencyCodes = Localization.isoCurrencyCodes;
      this.setState({ isoCurrencyCodes });
    }
  };

  prettyFormatCurrency = () => {
    let buffer = '';
    let seenCount = 0;
    const sample = this.state.isoCurrencyCodes.slice(0, 100);
    const grouped = chunk(sample, 10);
    let drilldownIndex = 0;
    let currentColumn = 0;
    while (true) {
      while (true) {
        if (seenCount === sample.length) return buffer;
        if (currentColumn === grouped.length) {
          currentColumn = 0;
          buffer += '\n';
          drilldownIndex++;
          continue;
        }
        buffer += `${grouped[currentColumn][drilldownIndex]}\t`;
        seenCount++;
        currentColumn++;
      }
    }
  };

  changeLocale = locale => {
    i18n.locale = locale;
    this.setState({ locale });
  };

  render() {
    const preferredLocales =
      this.state.preferredLocales && this.state.preferredLocales.length ? (
        <MonoText>{JSON.stringify(this.state.preferredLocales, null, 2)}</MonoText>
      ) : null;
    const currencyCodes =
      this.state.isoCurrencyCodes && this.state.isoCurrencyCodes.length ? (
        <MonoText>{this.prettyFormatCurrency()}</MonoText>
      ) : null;
    return (
      <ScrollView>
        <View style={styles.container}>
          <HeadingText>Current Locale</HeadingText>
          <MonoText>{JSON.stringify(this.state.currentLocale, null, 2)}</MonoText>

          <HeadingText>Locales in Preference Order</HeadingText>
          <ListButton title="Show preferred Locales" onPress={this.queryPreferredLocales} />
          {preferredLocales}

          <HeadingText>Currency Codes</HeadingText>
          <ListButton title="Show first 100 currency codes" onPress={this.queryCurrencyCodes} />
          {currencyCodes}

          <HeadingText>Localization Table</HeadingText>
          <Picker
            style={styles.picker}
            selectedValue={this.state.locale}
            onValueChange={this.changeLocale}>
            <Picker.Item label="🇺🇸 English" value="en" />
            <Picker.Item label="🇷🇺 Russian" value="ru" />
          </Picker>

          <MonoText>{JSON.stringify(Localization, null, 2)}</MonoText>

          <View style={styles.languageBox}>
            <View style={styles.row}>
              <Text>Exists in Both: </Text>
              <Text>{this.state.currentLocale ? i18n.t('phrase') : ''}</Text>
            </View>
            <View style={styles.row}>
              <Text>Default Case Only: </Text>
              <Text>{this.state.currentLocale ? i18n.t('default') : ''}</Text>
            </View>
          </View>
        </View>
      </ScrollView>
    );
  }
}
const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  languageBox: {
    padding: 10,
    borderWidth: 1,
  },
  picker: {
    borderWidth: 1,
    padding: 0,
    margin: 0,
  },
  container: {
    padding: 10,
  },
});
