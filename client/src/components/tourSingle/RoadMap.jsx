import { roadmapData } from "@/data/tourSingleContent";
import React, { useState } from "react";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";

function RoadMapItem({ elm, index, moveItem, icon }) {
  const [, ref] = useDrag({
    type: "roadmap-item",
    item: { index },
  });

  const [, drop] = useDrop({
    accept: "roadmap-item",
    hover(draggedItem) {
      if (draggedItem.index !== index) {
        moveItem(draggedItem.index, index);
        draggedItem.index = index;
      }
    },
  });

  return (
    <div className="roadmap__item" ref={(node) => ref(drop(node))}>
      {icon ? (
        <div className="roadmap__iconBig">
          <i className={icon}></i>
        </div>
      ) : (
        <div className="roadmap__icon"></div>
      )}
      <div className="roadmap__wrap">
        <div className="roadmap__title">{`Day ${index + 1}: ${elm.title}`}</div>
      </div>
    </div>
  );
}

export default function RoadMap() {
  const [items, setItems] = useState(
    roadmapData.map((item) => ({
      title: item.title.replace(/^Day \d+: /, ""),
      icon: item.icon,
    }))
  );
  const moveItem = (dragIndex, hoverIndex) => {
    const updatedItems = [...items];
    const [movedItem] = updatedItems.splice(dragIndex, 1);
    updatedItems.splice(hoverIndex, 0, movedItem);
    setItems(updatedItems);
  };

  return (
    <DndProvider backend={HTML5Backend}>
      <div className="roadmap">
        {items.map((elm, i) => (
          <RoadMapItem
            key={i}
            elm={elm}
            index={i}
            moveItem={moveItem}
            icon={roadmapData[i].icon} 
          />
        ))}
      </div>
    </DndProvider>
  );
}