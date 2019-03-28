import React from 'react';
import { View, requireNativeComponent } from 'react-native';

type Props = {
  colors: number[];
  locations?: number[] | null;
  startPoint?: Point | null;
  endPoint?: Point | null;
} & React.ComponentProps<typeof View>;

type Point = [number, number];

export default class NativeLinearGradient extends React.PureComponent<Props> {
  render() {
    return <BaseNativeLinearGradient {...this.props} />;
  }
}

const BaseNativeLinearGradient = requireNativeComponent('ExponentLinearGradient');
