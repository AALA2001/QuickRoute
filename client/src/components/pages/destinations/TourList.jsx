import React, { useEffect, useState, useRef } from "react";
import Stars from "@/components/common/Stars";
import Pagination from "@/components/common/Pagination";

import { Link, useNavigate } from "react-router-dom";
import EmptyDesign from "@/components/common/EmptyDesign";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";
import AddToPlanPopover from "@/components/common/AddToPlanPopover";

export default function TourList1({ data, destination }) {
  const [sortOption, setSortOption] = useState("");
  const [ddActives, setDdActives] = useState(false);
  const dropDownContainer = useRef();
  const navigate = useNavigate()


  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;


  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedTour, setSelectedTour] = useState(null);

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  useEffect(() => {
    const handleClick = (event) => {
      if (
        dropDownContainer.current &&
        !dropDownContainer.current.contains(event.target)
      ) {
        setDdActives(false);
      }
    };

    document.addEventListener("click", handleClick);

    return () => {
      document.removeEventListener("click", handleClick);
    };
  }, []);

  const handleOpenPopover = (event, elm) => {
    setAnchorEl(event.currentTarget);
    setSelectedTour(elm);
  };

  const handleClosePopover = () => {
    setAnchorEl(null);
    setSelectedTour(null);
  };

  const sortedData = [...data].sort((a, b) => {
    if (sortOption === "Most Rated") {
      return b.total_ratings - a.total_ratings;
    } else if (sortOption === "Least Rated") {
      return a.total_ratings - b.total_ratings;
    }
    return 0;
  });

  const paginatedList = sortedData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <section className="layout-pb-xl">
      <div className="container">
        <div className="row y-gap-10 justify-between items-end y-gap-10 mb-50 ">
          <div className="col-auto">
            <h2 className="text-30">
              Explore all things to do in {destination?.title} {new Date().getFullYear()}
            </h2>
          </div>

        </div>
        <div className="row">
          <div className="col-xl-12 col-lg-12">
            <div className="row y-gap-5 justify-between">
              <div className="col-auto">
                <div>{data?.length} results</div>
              </div>

              <div ref={dropDownContainer} className="col-auto">
                <div
                  className={`dropdown -type-2 js-dropdown js-form-dd ${ddActives ? "is-active" : ""
                    } `}
                  data-main-value=""
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
                        setSortOption((pre) => (pre == "Most Rated" ? "" : "Most Rated"));
                        setDdActives(false);
                      }}
                      className="dropdown__item"
                      data-value="fast"
                    >
                      Most Rated
                    </div>
                    <div
                      onClick={() => {
                        setSortOption((pre) => (pre == "Least Rated" ? "" : "Least Rated"));
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

            {/* card */}
            <div className="row y-gap-30 pt-30">
              {paginatedList.length == 0 && (<EmptyDesign />)}
              {paginatedList.length != 0 && paginatedList.map((elm, i) => (
                <div className="col-12" key={i} >
                  <div className="tourCard -type-2">
                    <div className="tourCard__image">
                      <Link to={`/tour-single/${elm?.location_id}`}>
                        <img src={`http://localhost:9091/${elm?.image}`} alt="image" />
                      </Link>

                      <div className="tourCard__favorite">
                        <button
                          className="button -accent-1 size-35 bg-white rounded-full flex-center"
                          onClick={() => {
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
                          }}
                        >
                          <i className="icon-heart text-15"></i>
                        </button>
                      </div>
                    </div>

                    <div className="tourCard__content">
                      <div className="tourCard__location">
                        <i className="icon-pin"></i>
                        {elm.destination_title}, {elm.country_name}
                      </div>

                      <Link to={`/tour-single/${elm?.location_id}`}>
                        <h3 className="tourCard__title mt-5">
                          <span>{elm.title}</span>
                        </h3>
                      </Link>


                      {elm.total_ratings == 0 ? (<span>no reviews</span>) : (
                        <div className="tourCard__rating d-flex items-center text-13 mt-5">
                          <div className="d-flex x-gap-5">
                            <Stars star={elm.average_rating} black={true} font={12} />
                          </div>
                          <span className="text-dark-1 ml-10">
                            {elm.rating} ({elm.total_ratings})
                          </span>
                        </div>
                      )}

                      <p className="tourCard__text mt-5">{elm?.overview.length > 500 ? elm.overview.substring(0, 500) + '...' : elm.overview}</p>

                    </div>

                    <div className="tourCard__info d-flex justify-center">
                      <button
                        className="button -outline-accent-1 text-accent-1 p-10 h-50 d-flex justify-center align-items-center"
                        onClick={(e) => handleOpenPopover(e, elm)}
                      >
                        <span><i className="icon-arrow-top-right ml-10"></i> Add to Plan</span>
                      </button>
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
        </div>
      </div>
      {selectedTour && (
        <AddToPlanPopover
          anchorEl={anchorEl}
          handleClose={handleClosePopover}
          elm={selectedTour}
        />
      )}
    </section>
  );
}
