import React, { useEffect, useState } from "react";
export default function Country({ active, setCountry, onSelect }) {
    const [countries, setCountries] = useState([]);
    useEffect(() => {
        fetch(`http://localhost:9093/clientData/countries`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                setCountries(data);
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
                    {countries.map((elm, i) => (
                        <div
                            onClick={() =>
                            {
                                setCountry((pre) => (pre == elm.name ? "" : elm.name))
                                onSelect(elm.id)
                            }
                            }
                            key={i}
                            className="searchFormItemDropdown__item"
                        >
                            <button className="js-select-control-button">
                                <span className="js-select-control-choice">{elm.name}</span>
                            </button>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
