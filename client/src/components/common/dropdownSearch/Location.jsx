import React, { useEffect, useState } from "react";
import { locations } from "@/data/searchDDLocations";
export default function Location({ active, setLocation, onSelect }) {
  const [destinations, setDestinations] = useState([]);
    useEffect(() => {
        fetch(`http://localhost:9093/clientData/destinations`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                setDestinations(data);
            })
            .catch(error => console.error(error));
    }, []);
  return (
    <div
      className={`searchFormItemDropdown -location ${active ? "is-active" : ""
        } `}
      data-x="location"
      data-x-toggle="is-active"
    >
      <div className="searchFormItemDropdown__container">
        <div className="searchFormItemDropdown__list sroll-bar-1">
          {destinations.map((elm, i) => (
            <div
              onClick={() => {
                setLocation((pre) => (pre == elm.title ? "" : elm.title))
                onSelect(elm.id)
              }
              }
              key={i}
              className="searchFormItemDropdown__item"
            >
              <button className="js-select-control-button">
                <span className="js-select-control-choice">{elm.title}</span>
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
