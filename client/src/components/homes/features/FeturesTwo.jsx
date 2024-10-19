import { featuresTwo } from "@/data/features";

import { Link } from "react-router-dom";
import React from "react";

export default function FeturesTwo({ data }) {
  console.log(data)
  return (
    <section className="relative mt-20  mb-80">
      <div className="relative xl:unset container">
        <div className="layout-pt-xl layout-pb-xl rounded-12">
          <div className="sectionBg">
            <img
              src="/img/about/1/1.png"
              alt="image"
              className="img-ratio rounded-12 md:rounded-0"
            />
          </div>

          <div className="row y-gap-30 justify-center items-center">
            <div className="col-lg-4 col-md-6">
              <h2
                data-aos="fade-up"
                data-aos-delay=""
                className="text-40 lh-13"
              >
                We Make
                <br className="md:d-none" />
                World Travel Easy
              </h2>

              <p data-aos="fade-up" data-aos-delay="" className="mt-10">
                Experience seamless travel planning with our application. 
                Effortlessly create personalized itineraries that guide you to top attractions and hidden gems, all tailored to your preferences.
              </p>
              <button
                data-aos="fade-right"
                data-aos-delay=""
                className="button -md -dark-1 bg-accent-1 text-white mt-60 md:mt-30"
              >
                <Link to={"/tour-list"}>
                  Explore Our Tours
                  <i className="icon-arrow-top-right ml-10"></i>
                </Link>
              </button>
            </div>

            <div className="col-md-6">
              <div
                data-aos="fade-left"
                data-aos-delay=""
                className="featuresGrid"
              >
                <div
                  className="featuresGrid__item px-40 py-40 text-center bg-white rounded-12"
                >
                  <img src={"/img/icons/2/1.svg"} alt="icon" />
                  <div className="text-40 fw-700 text-accent-1 mt-20 lh-14">
                    {data?.destination_count}
                  </div>
                  <div>Total Destinations</div>
                </div>
                <div
                  className="featuresGrid__item px-40 py-40 text-center bg-white rounded-12"
                >
                  <img src={"/img/icons/2/2.svg"} alt="icon" />
                  <div className="text-40 fw-700 text-accent-1 mt-20 lh-14">
                    {data?.destination_location_count}
                  </div>
                  <div>Amazing Tours Locations</div>
                </div>
                <div
                  className="featuresGrid__item px-40 py-40 text-center bg-white rounded-12"
                >
                  <img src={"/img/icons/2/3.svg"} alt="icon" />
                  <div className="text-40 fw-700 text-accent-1 mt-20 lh-14">
                    {data?.users_count}
                  </div>
                  <div>Happy Customer</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
