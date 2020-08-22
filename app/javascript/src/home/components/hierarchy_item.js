import React from 'react';

const HierarchyItem = props => {
  const { item } = props;

  return (
    <div className='entity-box'>
      {item.name}
    </div>
  );
}

export default HierarchyItem;
