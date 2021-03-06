import * as React from 'react';
import PropTypes from 'prop-types';
import { View, ViewPropTypes } from 'react-native';
import { requireNativeViewManager } from 'expo-core';
export default class AdMobBanner extends React.Component {
    constructor() {
        super(...arguments);
        this.state = { style: {} };
        this._handleSizeChange = ({ nativeEvent }) => {
            const { height, width } = nativeEvent;
            this.setState({ style: { width, height } });
        };
        this._handleDidFailToReceiveAdWithError = ({ nativeEvent }) => this.props.onDidFailToReceiveAdWithError &&
            this.props.onDidFailToReceiveAdWithError(nativeEvent.error);
    }
    render() {
        return (<View style={this.props.style}>
        <ExpoBannerView style={this.state.style} adUnitID={this.props.adUnitID} bannerSize={this.props.bannerSize} testDeviceID={this.props.testDeviceID} onSizeChange={this._handleSizeChange} onAdViewDidReceiveAd={this.props.onAdViewDidReceiveAd} onDidFailToReceiveAdWithError={this._handleDidFailToReceiveAdWithError} onAdViewWillPresentScreen={this.props.onAdViewWillPresentScreen} onAdViewWillDismissScreen={this.props.onAdViewWillDismissScreen} onAdViewDidDismissScreen={this.props.onAdViewDidDismissScreen} onAdViewWillLeaveApplication={this.props.onAdViewWillLeaveApplication}/>
      </View>);
    }
}
AdMobBanner.propTypes = {
    bannerSize: PropTypes.oneOf([
        'banner',
        'largeBanner',
        'mediumRectangle',
        'fullBanner',
        'leaderboard',
        'smartBannerPortrait',
        'smartBannerLandscape',
    ]),
    adUnitID: PropTypes.string,
    testDeviceID: PropTypes.string,
    onAdViewDidReceiveAd: PropTypes.func,
    onDidFailToReceiveAdWithError: PropTypes.func,
    onAdViewWillPresentScreen: PropTypes.func,
    onAdViewWillDismissScreen: PropTypes.func,
    onAdViewDidDismissScreen: PropTypes.func,
    onAdViewWillLeaveApplication: PropTypes.func,
    ...ViewPropTypes,
};
AdMobBanner.defaultProps = { bannerSize: 'smartBannerPortrait' };
const ExpoBannerView = requireNativeViewManager('ExpoAdsAdMobBannerView');
//# sourceMappingURL=AdMobBanner.js.map