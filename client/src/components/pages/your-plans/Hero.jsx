import React, { useState } from "react";

export default function Hero({ onSearchTextChange }) {
  const [inputValue, setInputValue] = useState("");
  const handleInputChange = (e) => {
    const value = e.target.value;
    setInputValue(value);
    onSearchTextChange(value);
  };
  return (
    <section className="pageHeader -type-2">
      <div className="pageHeader__bg">
        <img src="/img/pageHeader/2.jpg" alt="image" />
        <img src="/img/hero/1/shape.svg" alt="image" />
      </div>

      <div className="container">
        <div className="row justify-center">
          <div className="col-12">
            <div className="pageHeader__content">
              <h1 className="pageHeader__title">Your Plans</h1>

              <p className="pageHeader__text">
                Personalized your plans
              </p>

              <div className="pageHeader__search">
                <input type="text" placeholder="Search for a topic" value={inputValue}  onChange={handleInputChange} />
                <button>
                  <i className="icon-search text-15 text-white"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
