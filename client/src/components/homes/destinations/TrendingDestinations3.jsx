import { destinationCards2 } from "@/data/destinations";

import { Link } from "react-router-dom";
import React from "react";

export default function TrendingDestinations3({ data }) {
  return (
    <section className="layout-pt-lg layout-pb-lg">
      <div className="container">
        <div className="row y-gap-15 justify-between items-end">
          <div className="col-auto">
            <h2
              data-aos="fade-up"
              data-aos-delay=""
              className="text-30 md:text-24"
            >
              Destinations
            </h2>
          </div>
        </div>

        <div
          data-aos="fade-up"
          data-aos-delay=""
          className="row y-gap-30 pt-40 sm:pt-20"
        >
          {data.map((elm, i) => (
            <div key={i} className="col-lg-3 col-sm-6">
              <Link
                to={`/destinations/${elm?.id}`}
                className="featureCard -type-6 -hover-image-scale"
              >
                <div className="featureCard__image -hover-image-scale__image rounded-12 h-200">
                  <img
                    src={`http://localhost:9091/${elm.destination_image}`}
                    alt="image" />
                </div>

                <div className="featureCard__content">
                  <h3 className="text-16 fw-500 text-white">{elm.destination_title}</h3>
                  <p className="text-white lh-16">{elm.location_count == 1 ? 1 : elm.location_count - 1}+ Tours</p>

                </div>
              </Link>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
