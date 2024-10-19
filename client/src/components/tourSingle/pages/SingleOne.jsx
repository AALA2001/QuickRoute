import React, { useEffect, useState } from "react";
import MainInformation from "../MainInformation";
import OthersInformation from "../OthersInformation";
import Overview from "../Overview";
import Included from "../Included";
import Map from "@/components/tours/Map";
import Faq from "../Faq";
import Rating from "../Rating";
import Reviews from "../Reviews";
import TourSingleSidebar from "../TourSingleSidebar";
import Gallery1 from "../Galleries/Gallery1";
import DateCalender from "../DateCalender";
import RoadMap2 from "../Roadmap2";
import CommentBox from "../CommentBox";

export default function SingleOne({ tour,id }) {
  return (
    <>
      <section className="">
        <div className="container">
          <MainInformation tour={tour[0]} id={id}/>
          <Gallery1 tour={tour[0]} />
        </div>
      </section>

      <section className="layout-pt-md js-pin-container">
        <div className="container">
          <div className="row y-gap-30 justify-between">
            <div className="col-lg-12">

              <Overview tour={tour[0]} />

              <div className="line mt-60 mb-60"></div>
              <CommentBox locationId={tour[0]?.location_id}/>
              <div className="line mt-60 mb-60"></div>

              <h2 className="text-30">Customer Reviews</h2>

              <Reviews tour={tour[0]} />
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
