import { destinationsFive } from "@/data/destinations";

import { Link, useNavigate } from "react-router-dom";
import React from "react";

export default function PopulerDestinations() {
  const navigate = useNavigate()
  return (
    <section className="layout-pt-xl mb-80">
      <div className="container">
        <div className="row justify-between items-end y-gap-10">
          <div className="col-auto">
            <h2 data-aos="fade-up" data-aos-delay="" className="text-30">
              Tour Types
            </h2>
          </div>

        </div>

        <div
          data-aos="fade-up"
          data-aos-delay=""
          className="grid -type-3 pt-40 sm:pt-20"
        >
          {destinationsFive.map((elm, i) => (
            <div onClick={() => navigate('/tour-list', { state: { tourType: elm.title } })}
              key={i}
              className="featureCard -type-1 overflow-hidden rounded-12 px-30 py-30 -hover-image-scale "
              style={{cursor: 'pointer'}}
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
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
