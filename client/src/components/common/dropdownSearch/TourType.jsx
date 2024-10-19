import React, { useEffect, useState } from "react";
const options = [
  "City Tour",
  "Hiking",
  "Food Tour",
  "Cultural Tours",
  "Museums Tours",
  "Beach Tours",
];
export default function TourType({ active, setTourType, onSelect }) {
  const [tourTypes, setTourTypes] = useState([]);
  useEffect(() => {
    fetch(`http://localhost:9093/clientData/tourTypes`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include'
    })
      .then(response => response.json())
      .then(data => {
        setTourTypes(data);
      })
      .catch(error => console.error(error));
  }, []);
  return (
    <div
      className={`searchFormItemDropdown -tour-type ${active ? "is-active" : ""
        } `}
      data-x="tour-type"
      data-x-toggle="is-active"
    >
      <div className="searchFormItemDropdown__container">
        <div className="searchFormItemDropdown__list sroll-bar-1">
          {tourTypes.map((elm, i) => (
            <div
              onClick={() => {
                setTourType((pre) => (pre == elm.type ? "" : elm.type))
                console.log(elm.id)
                // onSelect(elm.id);
              }}
              key={i}
              className="searchFormItemDropdown__item"
            >
              <button className="js-select-control-button">
                <span className="js-select-control-choice">{elm.type}</span>
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
