import React from "react";

export default function Banner12() {
  return (
    <section className="cta -type-4">
      <div className="container">
        <div className="cta__content">
          <div className="row justify-between">
            <div className="col-xl-7 col-lg-8">
              <h2
                data-aos="fade-up"
                data-aos-delay=""
                className="text-24 lh-13"
              >
                7 Reasons to Plan a Trip to Lowa in {new Date().getFullYear()}
              </h2>

              <p data-aos="fade-up" data-aos-delay="" className="mt-10">
                River cruises, railroad adventures, and Frank Lloyd Wright
                architecture.
              </p>

              <button
                data-aos="fade-right"
                data-aos-delay=""
                className="button -md -accent-1 bg-dark-1 text-white mt-10"
              >
                Read Now
                <i className="icon-arrow-top-right ml-10"></i>
              </button>
            </div>
          </div>

          <div className="col-lg-6">
            <div className="cta__image">
              <img src="/img/cta/11/1.jpg" alt="image" />
              <img src="/img/cta/11/shape.svg" alt="image" />
              <img src="/img/cta/11/mobileShape.svg" alt="image" />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
