import { destinationsSeven } from "@/data/destinations";

import { Link } from "react-router-dom";
import React from "react";

export default function TrendingDestinations() {
  return (
    <section className="layout-pt-xl layout-pb-xl">
      <div className="container">
        <div className="row justify-between items-end y-gap-10">
          <div className="col-auto">
            <h2 data-aos="fade-up" data-aos-delay="" className="text-30">
              Trending Destinations
            </h2>
          </div>

          <div className="col-auto">
            <Link
              to={"/tour-list-1"}
              data-aos="fade-right"
              data-aos-delay=""
              className="buttonArrow d-flex items-center "
            >
              <span>See all</span>
              <i className="icon-arrow-top-right text-16 ml-10"></i>
            </Link>
          </div>
        </div>

        <div
          data-aos="fade-up"
          data-aos-delay=""
          className="grid -type-2 pt-40 sm:pt-20"
        >
          {destinationsSeven.map((elm, i) => (
            <a
              href="#"
              key={i}
              className="featureCard -type-1 overflow-hidden rounded-12 px-30 py-30 -hover-image-scale"
            >
              <div className="featureCard__image -hover-image-scale__image">
                <img
                  style={{ objectFit: "cover" }}
                  src={elm.imgSrc}
                  alt="image"
                />
              </div>

              <div className="featureCard__content">
                <h4 className="text-white">{elm.title}</h4>
              </div>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
