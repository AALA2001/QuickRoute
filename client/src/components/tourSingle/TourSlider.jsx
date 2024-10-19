import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Pagination } from "swiper/modules";
import { tourData } from "@/data/tours";

import Stars from "../common/Stars";
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import AddToPlanPopover from "../common/AddToPlanPopover";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import toast from "react-hot-toast";

export default function TourSlider({ related = [], locationId }) {
  const [selectedTour, setSelectedTour] = useState(null);
  const [anchorEl, setAnchorEl] = useState(null);
  const navigate = useNavigate()
  console.log(related.length)
  const handleOpenPopover = (event, elm) => {
    setAnchorEl(event.currentTarget);
    setSelectedTour(elm);
  };

  const handleClosePopover = () => {
    setAnchorEl(null);
    setSelectedTour(null);
  };
  return (
    <section className="layout-pt-xl layout-pb-xl">
      <div className="container">
        <div className="row">
          <div className="col-auto">
            <h2 className="text-30">You might also like...</h2>
          </div>
        </div>
        <div className="relative pt-40 sm:pt-20">
          <div
            className="overflow-hidden pb-5 js-section-slider"
            data-gap="30"
            data-slider-cols="xl-4 lg-3 md-2 sm-1 base-1"
            data-nav-prev="js-slider1-prev"
            data-nav-next="js-slider1-next"
          >
            {related.length === 0 && (<p>No related locations</p>)}
            <div className="swiper-wrapper">
              <Swiper
                spaceBetween={30}
                // className="bg-accent-1"
                pagination={{
                  el: ".pbutton1",
                  clickable: true,
                }}
                style={{ width: "100%" }}
                navigation={{
                  prevEl: ".js-slider10-prev",
                  nextEl: ".js-slider10-next",
                }}
                modules={[Navigation, Pagination]}
                breakpoints={{
                  500: {
                    slidesPerView: 1,
                  },
                  768: {
                    slidesPerView: 2,
                  },
                  1024: {
                    slidesPerView: 3,
                  },
                  1200: {
                    slidesPerView: 4,
                  },
                }}
              >
                {related.length !== 0 && related.map((elm, i) => (
                  <SwiperSlide key={i}>
                    <Link
                      // style={{ width: '700px' }}
                      to={`/tour-single/${locationId}`}
                      className="tourCard -type-1 py-10 px-10 border-1 rounded-12 bg-white -hover-shadow"
                    >
                      <div className="tourCard__header ">
                        <div className="tourCard__image ratio ratio-28:20">
                          <img
                            src={`http://localhost:9091/${elm.image}`}
                            alt="image"
                            className="img-ratio rounded-12"
                          />
                        </div>

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
                          {elm.destination_title},{elm.country_name}
                        </div>
                        <h3 className="tourCard__title text-16 fw-500 mt-5">
                          <span>{elm.title}</span>
                        </h3>

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
                    </Link>
                  </SwiperSlide>
                ))}
              </Swiper>
            </div>
          </div>

          <div className="navAbsolute">
            <button className="navAbsolute__button bg-white js-slider10-prev">
              <i className="icon-arrow-left text-14"></i>
            </button>

            <button className="navAbsolute__button bg-white js-slider10-next">
              <i className="icon-arrow-right text-14"></i>
            </button>
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
