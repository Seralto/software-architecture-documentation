import React from 'react';

import { v4 as uuidv4 } from 'uuid';

const HierarchyItem = props =>{
  const renderItem = item => {
    return (
      <li key={uuidv4()}>
        <a href='#'>{item.name}</a>

        <HierarchyItem hierarchy={item.hierarchy} />
      </li>
    )
  }

  const renderHierarchy = props => {
    const { hierarchy } = props;
    if (!hierarchy) { return null; }

    return hierarchy.map( item => renderItem(item))
  }

  return (
    <div>
      <ul>
        { renderHierarchy(props) }
      </ul>
    </div>
  );
}

export default HierarchyItem;
