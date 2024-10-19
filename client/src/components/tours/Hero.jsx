import Calender from "@/components/common/dropdownSearch/Calender";
import Location from "@/components/common/dropdownSearch/Location";
import TourType from "@/components/common/dropdownSearch/TourType";

import { useEffect, useState, useRef } from "react";
import Country from "../common/dropdownSearch/Country";
import { useLocation } from "react-router-dom";

export default function Hero({ onSearch }) {
  const { state } = useLocation();

  const [currentActiveDD, setCurrentActiveDD] = useState("");
  const [destination, setDestination] = useState(state?.destination || "");
  const [country, setCountry] = useState(state?.country || "");
  const [tourType, setTourType] = useState(state?.tourType || "");
  const [selectedTourType, setSelectedTourType] = useState("");
  const [selectedCountryId, setSelectedCountryId] = useState("");
  const [selectedDestinationId, setSelectedDestinationId] = useState("");


  useEffect(() => {
    setCurrentActiveDD("");
  }, [destination, country, tourType, setCurrentActiveDD]);

  const dropDownContainer = useRef();
  useEffect(() => {
    const handleClick = (event) => {
      if (
        dropDownContainer.current &&
        !dropDownContainer.current.contains(event.target)
      ) {
        setCurrentActiveDD("");
      }
    };

    document.addEventListener("click", handleClick);

    return () => {
      document.removeEventListener("click", handleClick);
    };
  }, []);
  const handleSearch = () => {
    // console.log(tourType,country,destination)
    onSearch(country, destination, tourType);
  };

  return (
    <>
      <section className="pageHeader -type-2 -secondary">
        <div className="pageHeader__bg">
          <img src="/img/pageHeader/2.jpg" alt="image" />
          <img
            src="/img/hero/1/shape.svg"
            style={{ height: "auto" }}
            alt="image"
          />
        </div>

        <div className="container">
          <div className="row justify-center">
            <div className="col-12">
              <div className="pageHeader__content">
                <h1 className="pageHeader__title">Tour List</h1>

                <p className="pageHeader__text">
                  Discover a variety of exciting tours and destinations, carefully curated to offer unique experiences.
                </p>

                <div className="pageHeader__search">
                  <div className="searchForm -type-1 shadow-1">
                    <div ref={dropDownContainer} className="searchForm__form">
                      <div className="searchFormItem js-select-control js-form-dd">
                        <div
                          className="searchFormItem__button"
                          onClick={() =>
                            setCurrentActiveDD((pre) =>
                              pre == "country" ? "" : "country",
                            )
                          }
                        >
                          <div className="searchFormItem__icon size-50 rounded-full bg-accent-1-05 flex-center">
                            <i className="text-20 icon-pin"></i>
                          </div>
                          <div className="searchFormItem__content">
                            <h5>Country</h5>
                            <div className="js-select-control-chosen">
                              {" "}
                              {country ? country : "Search country"}
                            </div>
                          </div>
                        </div>

                        <Country
                          setCountry={setCountry}
                          active={currentActiveDD === "country"}
                          onSelect={(id) => setSelectedCountryId(id)}
                        />
                      </div>

                      <div className="searchFormItem js-select-control js-form-dd js-form-dd">
                        <div
                          className="searchFormItem__button"

                          onClick={() =>
                            setCurrentActiveDD((pre) =>
                              pre == "destination" ? "" : "destination",
                            )
                          }
                        >
                          <div className="searchFormItem__icon size-50 rounded-full bg-accent-1-05 flex-center">
                            <i className="text-20 icon-calendar"></i>
                          </div>
                          <div className="searchFormItem__content">
                            <h5>Destination</h5>
                            <div>
                              <span className="js-select-control-chosen">
                                {" "}
                                {destination ? destination : "Search destinations"}
                              </span>
                              <span className="js-last-date"></span>
                            </div>
                          </div>
                        </div>
                        <Location
                          setLocation={setDestination}
                          active={currentActiveDD === "destination"}
                          onSelect={(id) => setSelectedDestinationId(id)}
                        />
                      </div>

                      <div className="searchFormItem js-select-control js-form-dd">
                        <div
                          className="searchFormItem__button"
                          onClick={() =>
                            setCurrentActiveDD((pre) =>
                              pre == "tourType" ? "" : "tourType",
                            )
                          }
                        >
                          <div className="searchFormItem__icon size-50 rounded-12 border-1 flex-center">
                            <i className="text-20 icon-flag"></i>
                          </div>
                          <div className="searchFormItem__content">
                            <h5>Tour Type</h5>
                            <div className="js-select-control-chosen">
                              {tourType ? tourType : "All tour"}
                            </div>
                          </div>
                        </div>

                        <TourType
                          setTourType={setTourType}
                          active={currentActiveDD === "tourType"}
                          onSelect={(text) => setSelectedTourType(text)}
                        />
                      </div>
                    </div>

                    <div className="searchForm__button">
                      <button onClick={handleSearch} className="button -dark-1 bg-accent-1 text-white">
                        <i className="icon-search text-16 mr-10"></i>
                        Search
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
