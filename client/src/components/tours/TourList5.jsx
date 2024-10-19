import { tourDataThree } from "@/data/tours";
import React, { useState, useRef, useEffect } from "react";
import Stars from "../common/Stars";
import Pagination from "../common/Pagination";
import {
  durations,
  features,
  languages,
  rating,
  speedFeatures,
} from "@/data/tourFilteringOptions";
import RangeSlider from "../common/RangeSlider";

import { Link, useNavigate } from "react-router-dom";
import AddToPlanPopover from "../common/AddToPlanPopover";
import { Skeleton } from "@mui/material";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";
import EmptyDesign from "../common/EmptyDesign";

export default function TourList5({ data }) {
  const [imageLoading, setImageLoading] = useState(false);

  const [sortOption, setSortOption] = useState("");
  const [ddActives, setDdActives] = useState(false);
  const dropDownContainer = useRef();
  const dropDownContainer2 = useRef();
  const navigate = useNavigate();

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedTour, setSelectedTour] = useState(null);

  const [selectedRatings, setSelectedRatings] = useState([]);

  const handleRatingChange = (ratingValue) => {
    console.log(ratingValue)
    setSelectedRatings((prev) =>
      prev.includes(ratingValue)
        ? prev.filter((r) => r !== ratingValue)
        : [...prev, ratingValue]
    );
  };

  const handleOpenPopover = (event, elm) => {
    setAnchorEl(event.currentTarget);
    setSelectedTour(elm);
  };

  const handleClosePopover = () => {
    setAnchorEl(null);
    setSelectedTour(null);
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const filteredData = data.filter((elm) =>
    selectedRatings.length === 0 || selectedRatings.includes(Math.floor(elm.average_rating))
  );

  const sortedData = [...filteredData].sort((a, b) => {
    if (sortOption === "most-rated") {
      return b.average_rating - a.average_rating;
    } else if (sortOption === "least-rated") {
      return a.average_rating - b.average_rating;
    }
    return 0;
  });

  const paginatedList = sortedData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const [curentDD, setCurentDD] = useState("");

  useEffect(() => {
    const handleClick = (event) => {
      if (
        dropDownContainer.current &&
        !dropDownContainer.current.contains(event.target)
      ) {
        setDdActives(false);
      }
      if (
        dropDownContainer2.current &&
        !dropDownContainer2.current.contains(event.target)
      ) {
        setCurentDD("");
      }
    };

    document.addEventListener("click", handleClick);

    return () => {
      document.removeEventListener("click", handleClick);
    };
  }, []);
  return (
    <section className="layout-pt-lg layout-pb-xl">
      <div className="container">
        <div className="row  custom-dd-container justify-between items-center relative z-5">
          <div className="col-auto">
            <div
              ref={dropDownContainer2}
              className="row  custom-dd-container2 custom-dd-container x-gap-10 y-gap-10 items-center"
            >

              <div className="col-auto">
                <div
                  className={` dropdown -base -price js-dropdown js-form-dd  ${curentDD == "ratingFilter1" ? "is-active" : ""
                    } `}
                >
                  <div
                    onClick={() => {
                      setCurentDD((pre) =>
                        pre == "ratingFilter1" ? "" : "ratingFilter1",
                      );
                    }}
                    className="dropdown__button h-50 min-w-auto js-button"
                  >
                    <span className="js-title">Rating</span>
                    <i className="icon-chevron-down ml-10"></i>
                  </div>

                  <div className="dropdown__menu px-30 py-30 shadow-1 border-1 js-">
                    <h5 className="text-18 fw-500">Rating</h5>
                    <div className="pt-20">
                      <div className="d-flex flex-column y-gap-15">
                        {rating.map((elm, i) => (
                          <div key={i} className="d-flex">
                            <div className="form-checkbox">
                              <input type="checkbox" name="rating" checked={selectedRatings.includes(elm)} onChange={() => handleRatingChange(elm)} />
                              <div className="form-checkbox__mark">
                                <div className="form-checkbox__icon">
                                  <img src="/img/icons/check.svg" alt="icon" />
                                </div>
                              </div>
                            </div>
                            <div className="d-flex x-gap-5 ml-10">
                              <Stars star={elm} font={13} />
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div ref={dropDownContainer} className="col-auto">
            <div
              className={`dropdown -type-2 js-dropdown js-form-dd ${ddActives ? "is-active" : ""
                } `}
            >
              <div
                className="dropdown__button js-button"
                onClick={() => setDdActives((pre) => !pre)}
              >
                <span>Sort by: </span>
                <span className="js-title">
                  {sortOption ? sortOption : "Select Option"}
                </span>
                <i className="icon-chevron-down"></i>
              </div>

              <div className="dropdown__menu js-menu-items">
                <div
                  onClick={() => {
                    setSortOption((pre) => (pre == "most-rated" ? "" : "most-rated"));
                    setDdActives(false);
                  }}
                  className="dropdown__item"
                  data-value="fast"
                >
                  Most Rated
                </div>
                <div
                  onClick={() => {
                    setSortOption((pre) => (pre == "least-rated" ? "" : "least-rated"));
                    setDdActives(false);
                  }}
                  className="dropdown__item"
                  data-value="fast"
                >
                  Least Rated
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="row y-gap-30 pt-30">
          {paginatedList.length == 0 && (<>
            <EmptyDesign />
          </>)}
          {paginatedList.map((elm, i) => (
            <div key={i} className="col-lg-3 col-sm-6">
              <div

                className="tourCard -type-1 py-10 px-10 border-1 rounded-12  -hover-shadow"
              >
                <div className="tourCard__header">
                  <Link to={`/tour-single/${elm.location_id}`} className="tourCard__image ratio ratio-28:20">
                    <img
                      src={`http://localhost:9091/${elm.image}`}
                      alt={elm.title}
                      className="img-ratio rounded-12"
                      loading="lazy"
                      onLoad={() => {
                        setImageLoading(true)
                      }}
                    />
                  </Link>

                  <button className=" mr-45 tourCard__favorite" onClick={() => {
                    const location_id = elm.location_id
                    var token = localStorage.getItem("token");
                    if (token == null) {
                      toast.error("You need to log into your account first");
                      navigate("/login")
                    } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
                      toast.error("Your session has expired, please log in again");
                      navigate("/login")
                    } else {
                      fetch(`http://localhost:9093/clientData/user/wishlist/add/${token}?destinations_id=${location_id}`)
                        .then((data) => {
                          if (data.ok) {
                            return data.json();
                          } else {
                            toast.error("Failed to fetch wishlist");
                          }
                        })
                        .then((response) => {
                          if (response.success) {
                            toast.success("Added to wishlist");
                          } else {
                            toast.error("Failed to add to wishlist");
                          }
                        })
                        .catch((error => console.log(error)))
                    }
                  }}>
                    <i className="icon-heart"></i>
                  </button>

                  <button className="tourCard__favorite" onClick={(e) => handleOpenPopover(e, elm)}>
                    <i className="icon-plus"></i>
                  </button>
                </div>

                <div className="tourCard__content px-10 pt-10">
                  <div className="tourCard__location d-flex items-center text-13 text-light-2">
                    <i className="icon-pin d-flex text-16 text-light-2 mr-5"></i>
                    {elm.destination_title}, {elm.country_name}
                  </div>

                  <Link to={`/tour-single/${elm.location_id}`} >
                    <h3 className="tourCard__title text-16 fw-500 mt-5">
                      <span>{elm.title}</span>
                    </h3>
                  </Link>
                  {elm.total_ratings == 0 ? (<span>no reviews</span>) : (
                    <div className="tourCard__rating d-flex items-center text-13 mt-5">
                      <div className="d-flex x-gap-5">
                        <Stars star={elm.average_rating} black={true} />
                      </div>
                      <span className="text-dark-1 ml-10">
                        {elm.rating} ({elm.total_ratings})
                      </span>
                    </div>
                  )}
                  <div className="d-flex justify-between items-center border-1-top text-13 text-dark-1 pt-10 mt-10">
                    <p className="tourCard__text tourCard__text--clamp mt-5">{elm.overview}</p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="d-flex justify-center flex-column mt-60">
          {data.length != 0 && (
            <Pagination
              totalItems={data.length}
              itemsPerPage={itemsPerPage}
              currentPage={currentPage}
              onPageChange={handlePageChange}
            />

          )}

          {data.length != 0 && (
            <div className="text-14 text-center mt-20">
              Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, paginatedList.length)} of {data.length}
            </div>
          )}
        </div>
      </div>
      {selectedTour && (
        <AddToPlanPopover
          anchorEl={anchorEl}
          handleClose={handleClosePopover}
          elm={selectedTour}
          destinations_id={selectedTour.location_id}
        />
      )}
    </section>
  );
}
