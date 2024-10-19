import React from "react";

export default function BannerFour() {
  return (
    <section className="layout-pt-xxl layout-pb-xxl relative mt-60 mb-80 ">
      <div className="sectionBg">
        <img src="/img/cta/3/banner.jpg" alt="image" className="img-ratio" />
      </div>

      <div className="container">
        <div className="row justify-center text-center">
          <div className="col-auto">
            <h2
              data-aos="fade-up"
              data-aos-delay=""
              className="text-70 md:text-40 sm:text-30 fw-700 text-white "
            >
              Adventure Starts Here
            </h2>
            <p
              data-aos="fade-up"
              data-aos-delay=""
              className="text-white mt-20"
            >
              Create your perfect travel itinerary with ease. Get personalized
              <br className="md:d-none" />day-by-day plans that match your interests and make every trip unforgettable.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
