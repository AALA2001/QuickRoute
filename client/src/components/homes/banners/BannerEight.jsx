import { Link } from "react-router-dom";
import React from "react";

export default function BannerEight() {
  return (
    <section className="cta -type-2 container ">
      <div className="cta__bg">
        <img src="/img/hero/2/bg.png" alt="image" />

        <div className="cta__image ">
          {/* <img src="/img/hero/2/shape.svg" alt="image" /> */}
          <img src="/img/cta/7/1.jpg" alt="image" />
          <img src="/img/hero/2/shape.svg" alt="image" />
          {/* <img src="/img/hero/2/shape2.svg" alt="image" /> */}
        </div>
      </div>

      <div className="container ">
        <div className="row layout-ps-xxl ps-4 ">
          <div className="col-xxl-4 col-xl-5 col-lg-6 col-md-7">
            <div className="cta__content ps-3">
              <h2
                data-aos="fade-up"
                data-aos-delay=""
                className="text-40 md:text-30  lh-13 text-white"
              >
                Find the
                <br className="lg:d-none" />
                Itinerary for Your
                <br className="lg:d-none" />
                Next Adventure
              </h2>
              <p data-aos="fade-up" data-aos-delay="" className="mt-10 text-white">
                Where will your next journey take you?
              </p>
              <d4v
                data-aos="fade-right"
                data-aos-delay=""
                className="mt-30 md:mt-20"
              >
                <button className="button -md -dark-1 mt-4  bg-white  text-accent-1 ">
                  <Link to="/your-plans">
                    Create a Plan
                    <i className="icon-arrow-top-right ml-10 text-16"></i>
                  </Link>
                </button>
              </d4v>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
