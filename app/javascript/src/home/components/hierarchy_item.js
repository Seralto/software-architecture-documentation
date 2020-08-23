import React from 'react';

const HierarchyItem = props => {
  const { item } = props;

  const capitalize = name => {
    return name.charAt(0).toUpperCase() + name.slice(1)
  }

  const buildMethodsList = (type, list) => {
    if (!list || list.length === 0) { return };

    return (
      <div className='methods-box'>
        <p className='method-type'><span>{capitalize(type)} methods</span></p>
        {list.map((method) => { return <span key={method} className='method-name'>{`${method}()`}</span> })}
      </div>
    )
  };

  return (
    <div className='entity-box'>
      <div className={`entity-box-header type-${item.type}`}>
        {item.name}<br/>
        <small>{item.type === 'class' ? 'Class' : 'Module'}</small>
      </div>

      <div className='entity-box-body'>
        {buildMethodsList('public', item.public_methods)}
        {buildMethodsList('class', item.class_methods)}
      </div>
    </div>
  );
}

export default HierarchyItem;
