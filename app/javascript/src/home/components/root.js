import React, { Component } from 'react';

import Api from '../api/api';

import HierarchyList from './hierarchy_list';

class Root extends Component {
  constructor(props) {
    super(props);

    this.state = {
      hierarchy: null
    };
  }

  componentDidMount() {
    Api.get()
      .then(hierarchy => {
        this.setState({ hierarchy: hierarchy.data })
      })
      .catch(_error => {
        console.log('opps: ', error);
      });
  }

  render() {
    const { hierarchy } = this.state;

    return (
      <div className='tree'>
        <h1>Hierarchy</h1>
        <HierarchyList hierarchy={hierarchy} />
      </div>
    );
  }
}

export default Root;
