import React from "react";
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Pagination } from "swiper/modules";
import { tourData } from "@/data/tours";
import Stars from "@/components/common/Stars";

import { Link } from "react-router-dom";

export default function TourSlider5({data}) {
  return (
    <>
      <section className="layout-pt-xl layout-pb-xl">
        <div className="container">
          <div className="row y-gap-10 justify-between items-center y-gap-10">
            <div className="col-auto">
              <h2 data-aos="fade-up" data-aos-delay="" className="text-30">
                Featured Trips
              </h2>
            </div>
          </div>

          <div className="relative pt-40 sm:pt-20">
            <div className="js-section-slider">
              <div data-aos="fade-up" data-aos-delay="" className="">
                <Swiper
                  spaceBetween={30}
                  className="w-100 overflow-visible"
                  navigation={{
                    prevEl: ".js-slider1-prev",
                    nextEl: ".js-slider1-next",
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
                      slidesPerView: 3,
                    },
                  }}
                >
                  {data.map((elm, i) => (
                    <SwiperSlide key={i}>
                      <Link
                        to={`/tour-single/${elm.destination_id}`}
                        className="tourCard -type-3 -hover-image-scale"
                      >
                        <div className="tourCard__image ratio ratio-41:45 rounded-12 -hover-image-scale__image">
                          <img
                            src={`http://localhost:9091/${elm.image}`}
                            alt="image"
                            className="img-ratio rounded-12"
                          />
                        </div>

                        <div className="tourCard__wrap">
                          <div className="tourCard__header d-flex justify-between items-center text-13 text-white">
                            <div className="d-flex items-center">
                              <i className="icon-clock text-16 mr-5"></i>
                              {elm.duration}
                            </div>

                            <button className="tourCard__favorite">
                              <i className="icon-heart"></i>
                            </button>
                          </div>

                          <div className="tourCard__content">
                            <div>
                              <div className="tourCard__location d-flex items-center text-13 text-white">
                                <i className="icon-pin d-flex text-16 text-white mr-5"></i>
                                {elm.destination_title} , {elm.country_name}
                              </div>

                              <h3 className="tourCard__title text-18 text-white fw-500 mt-5">
                                <span>{elm.title}</span>
                              </h3>

                              <div className="tourCard__rating d-flex items-center text-13 mt-5">
                                <div className="d-flex items-center x-gap-5">
                                  <Stars font={12} star={elm.average_rating} />
                                </div>

                                <span className="text-white ml-10">
                                  {elm.rating} ({elm.total_reviews})
                                </span>
                              </div>
                            </div>
                          </div>
                        </div>
                      </Link>
                    </SwiperSlide>
                  ))}
                </Swiper>
              </div>
            </div>

            <div className="navRegular mt-40 md:mt-30">
              <button className="navRegular__button bg-white js-slider1-prev">
                <i className="icon-arrow-left text-20"></i>
              </button>

              <button className="navRegular__button bg-white js-slider1-next">
                <i className="icon-arrow-right text-20"></i>
              </button>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
