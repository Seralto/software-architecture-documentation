import React from 'react';

import { v4 as uuidv4 } from 'uuid';

import HierarchyItem from './hierarchy_item';

const HierarchyList = props =>{
  const renderItem = item => {
    return (
      <li key={uuidv4()}>
        <HierarchyItem item={item} />

        { item.hierarchy.length > 0 && <HierarchyList hierarchy={item.hierarchy} /> }
      </li>
    )
  }

  const renderHierarchy = props => {
    const { hierarchy } = props;
    if (!hierarchy) { return null; }

    return hierarchy.map( item => renderItem(item))
  }

  return (
    <ul>
      { renderHierarchy(props) }
    </ul>
  );
}

export default HierarchyList;
