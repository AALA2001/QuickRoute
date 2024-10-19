import React, { useState } from "react";
import Stars from "@/components/common/Stars";

export default function Reviews({ reviews = [] }) {
  console.log(reviews)
  if (!reviews || reviews.length === 0) {
    return <p>No reviews available.</p>;
  }
  return (
    <>
      {reviews?.map((elm) => (
        <div key={elm.rating_id} className="pt-10">
          <div className="row justify-between">
            <div className="col-auto">
              <div className="d-flex items-center">
                <div className="size-50 rounded-full">
                  <img src={'../../../../public/img/avatars/profile.png'} alt="image" className="img-cover" />
                </div>

                <div className="text-16 fw-500 ml-20">{elm.first_name} {elm.last_name}</div>
              </div>
            </div>
          </div>

          <div className="d-flex items-center mt-15">
            <div className="d-flex x-gap-5">
              <Stars star={elm.rating_count} />
            </div>
            <div className="text-16 fw-500 ml-10">({elm.rating_count}.0)</div>
          </div>

          <p className="mt-10">{elm.review}</p>

          <div className="row x-gap-20 y-gap-20 pt-20">
            <div className="col-auto">
              <div className="size-130">
                <img
                  src={`http://localhost:9091/${elm.review_img}`}
                  alt="image"
                  className="img-cover rounded-12"
                />
              </div>
            </div>
          </div>

        </div>
      ))}
    </>
  );
}
