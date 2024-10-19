import { specialOffers } from "@/data/offer";

import { Link } from "react-router-dom";
import React from "react";

export default function SpacialOffer({ data }) {
  console.log(data)
  function formatDateTime(dateTime) {
    const { year, month, day, hour, minute } = dateTime;
    const formattedMonth = String(month).padStart(2, '0');
    const formattedDay = String(day).padStart(2, '0');
    const formattedMinute = String(minute).padStart(2, '0');

    const formattedHour = hour % 12 || 12;
    const amPm = hour >= 12 ? 'PM' : 'AM';

    return `${year}-${formattedMonth}-${formattedDay} ${formattedHour}.${formattedMinute} ${amPm}`;
  }
  return (
    <section className="layout-pt-xl">
      <div className="container">
        <div className="row justify-between items-end y-gap-10">
          <div className="col-auto">
            <h2
              data-aos="fade-up"
              data-aos-delay=""
              className="text-30 md:text-24"
            >
              Special Offers
            </h2>
          </div>
        </div>

        <div
          data-aos="fade-up"
          data-aos-delay=""
          className="specialCardGrid row y-gap-30 md:y-gap-20 pt-40 sm:pt-20"
        >
          {data?.map((elm, i) => (
            <div key={i} className="col-xl-4 col-lg-6 col-md-6">
              <div className="specialCard">
                <div className="specialCard__image">
                <img src={`http://localhost:9091/${elm.offer_image}`} alt="image" />
                </div>

                <div className="specialCard__content">
                  <h3 className="specialCard__title">
                    {elm.offer_title.split(" ").slice(0, 3).join(" ")}
                    <br />
                    {elm.offer_title.split(" ").slice(3).join(" ")}
                  </h3>
                  {elm.from_Date && (
                    <>
                      <div className="specialCard__text">Offer valid till</div>
                      <div className="specialCard__text">{formatDateTime(elm.from_Date)} - {formatDateTime(elm.to_Date)}</div>
                    </>
                  )}
                  <div className="tourCard__location d-flex items-center text-13 text-white">
                    <i className="icon-pin d-flex text-16 mr-5"></i>
                    {elm.destinations_name} , {elm.country}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
