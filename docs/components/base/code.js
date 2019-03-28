import styled, { keyframes, css } from 'react-emotion';
import Prism from 'prismjs';

import * as React from 'react';
import * as Constants from '~/common/constants';

const attributes = {
  'data-text': true,
};

const STYLES_CODE_BLOCK = css`
  color: ${Constants.colors.black80};
  font-family: ${Constants.fontFamilies.mono};
  font-size: 13px;
  line-height: 20px;
  white-space: inherit;
  padding: 0px;
  margin: 0px;

  .code-annotation {
    transition: 200ms ease all;
    transition-property: text-shadow, opacity;
    text-shadow: 1px 1px ${Constants.colors.black30};
  }

  .code-annotation:hover {
    cursor: pointer;
    animation: none;
    opacity: 0.8;
  }
`;

const STYLES_INLINE_CODE = css`
  color: ${Constants.colors.black80};
  font-family: ${Constants.fontFamilies.mono};
  font-size: 0.9rem;
  white-space: pre-wrap;
  display: inline;
  padding: 4px;
  margin: 2px;
  line-height: 20px;
  max-width: 100%;

  word-wrap: break-word;
  background-color: ${Constants.colors.blackRussian};
  vertical-align: middle;
  overflow-x: scroll;

  ::before {
    content: '';
  }

  ::after {
    content: '';
  }
`;

const STYLES_CODE_CONTAINER = css`
  border: 1px solid ${Constants.colors.border};
  padding: 24px;
  margin: 16px 0 16px 0;
  white-space: pre;
  overflow: auto;
  -webkit-overflow-scrolling: touch;
  background-color: rgba(0, 1, 31, 0.03);
  line-height: 1.2rem;
`;

export class Code extends React.Component {
  componentDidMount() {
    this._runTippy();
  }

  componentDidUpdate() {
    this._runTippy();
  }

  _runTippy() {
    if (process.browser) {
      tippy('.code-annotation', {
        theme: 'expo',
        placement: 'top',
        arrow: true,
        arrowType: 'round',
        interactive: true,
        distance: 20,
      });
    }
  }

  _escapeHtml(text) {
    return text.replace(/"/g, '&quot;');
  }

  _replaceCommentsWithAnnotations(value) {
    return value
      .replace(/<span class="token comment">\/\* @info (.*?)\*\/<\/span>\s*/g, (match, content) => {
        return `<span class="code-annotation" title="${this._escapeHtml(content)}">`;
      })
      .replace(/<span class="token comment">\/\* @end \*\/<\/span>(\n *)?/g, '</span>');
  }

  render() {
    let code = this.props.children;
    let { lang } = this.props;
    let html = code.toString();
    if (lang && !Prism.languages[lang]) {
      try {
        require('prismjs/components/prism-' + lang + '.js');
      } catch (e) {}
    }
    if (lang && Prism.languages[lang]) {
      html = Prism.highlight(html, Prism.languages[lang]);
      html = this._replaceCommentsWithAnnotations(html);
    }

    // Remove leading newline if it exists (because inside <pre> all whitespace is dislayed as is by the browser, and
    // sometimes, Prism adds a newline before the code)
    if (html.startsWith('\n')) {
      html = html.replace('\n', '');
    }

    return (
      <pre className={STYLES_CODE_CONTAINER} {...attributes}>
        <code className={STYLES_CODE_BLOCK} dangerouslySetInnerHTML={{ __html: html }} />
      </pre>
    );
  }
}

export const InlineCode = ({ children }) => <code className={`${STYLES_INLINE_CODE} inline`}>{children}</code>;
