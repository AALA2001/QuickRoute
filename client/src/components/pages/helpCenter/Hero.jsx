import React from "react";

export default function Hero() {
  return (
    <section className="pageHeader -type-2">
      <div className="pageHeader__bg">
        <img src="/img/pageHeader/2.jpg" alt="image" />
        <img src="/img/hero/1/shape.svg" alt="image" />
      </div>

      <div className="container">
        <div className="row justify-center">
          <div className="col-12">
            <div className="pageHeader__content">
              <h1 className="pageHeader__title">Welcome to the Help Center</h1>

              <p className="pageHeader__text">
                Lorem ipsum is placeholder text commonly used in site.
              </p>

              <div className="pageHeader__search">
                <input type="text" placeholder="Search for a topic" />
                <button>
                  <i className="icon-search text-15 text-white"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
