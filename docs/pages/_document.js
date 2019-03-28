import Document, { Head, Main, NextScript } from 'next/document';
import { extractCritical } from 'emotion-server';
import { hydrate } from 'react-emotion';

import * as React from 'react';
import * as Constants from '~/common/constants';
import * as Analytics from '~/common/analytics';

import { globalReset } from '~/global-styles/reset';
import { globalNProgress } from '~/global-styles/nprogress';
import { globalTables } from '~/global-styles/tables';
import { globalFonts } from '~/global-styles/fonts';
import { globalPrism } from '~/global-styles/prism';
import { globalTippy } from '~/global-styles/tippy';

import { LATEST_VERSION } from '~/common/versions';

if (typeof window !== 'undefined') {
  hydrate(window.__NEXT_DATA__.ids);
}

export default class MyDocument extends Document {
  static getInitialProps({ renderPage }) {
    const page = renderPage();
    const styles = extractCritical(page.html);
    return { ...page, ...styles };
  }

  constructor(props) {
    super(props);
    const { __NEXT_DATA__, ids } = props;
    if (ids) {
      __NEXT_DATA__.ids = ids;
    }
  }

  render() {
    return (
      <html>
        <Head>
          <Analytics.GoogleScript id="UA-107832480-3" />
          <script src="/static/libs/prism/prism.js" />
          <script src="/static/libs/tippy/tippy.all.min.js" />
          <script src="/static/libs/nprogress/nprogress.js" />

          <style dangerouslySetInnerHTML={{ __html: this.props.css }} />

          <script
            dangerouslySetInnerHTML={{
              __html: `
             window._NODE_ENV = '${process.env.NODE_ENV}';
             window._LATEST_VERSION = '${LATEST_VERSION}';
              `,
            }}
          />

          <style dangerouslySetInnerHTML={{ __html: globalFonts }} />
          <style dangerouslySetInnerHTML={{ __html: globalReset }} />
          <style dangerouslySetInnerHTML={{ __html: globalNProgress }} />
          <style dangerouslySetInnerHTML={{ __html: globalTables }} />
          <style dangerouslySetInnerHTML={{ __html: globalPrism }} />
          <style dangerouslySetInnerHTML={{ __html: globalTippy }} />
          <link href="/static/libs/algolia/algolia.min.css" rel="stylesheet" />
        </Head>
        <body>
          <Main />
          <NextScript />
        </body>
      </html>
    );
  }
}
