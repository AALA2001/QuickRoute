import React from "react";
import ReviewBox from "../ReviewBox";

export default function ReviewsComment() {
  return (
    <>
      <section className="layout-pt-md js-pin-container mb-25">
        <div className="container">
          <div className="row y-gap-0 justify-content-center">
            <div className="col-lg-12 d-flex justify-content-center">
              <div
                className="shadow-1 border-1 p-5 rounded-20"
                style={{ width: "70%" }}
              >
                <ReviewBox/>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
