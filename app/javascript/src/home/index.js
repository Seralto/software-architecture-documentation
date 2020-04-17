import React from 'react';
import ReactDOM from 'react-dom';

import Root from './components/root';

const home = () => {
  ReactDOM.render(<Root />, document.getElementById('root'));
};

document.addEventListener('DOMContentLoaded', home);
