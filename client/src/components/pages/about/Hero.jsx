import React from "react";

export default function Hero() {
  return (
    <section className="pageHeader -type-1">
      <div className="pageHeader__bg">
        <img src="/img/pageHeader/1.jpg" alt="image" />
        <img src="/img/hero/1/shape.svg" alt="image" />
      </div>

      <div className="container">
        <div className="row justify-center">
          <div className="col-12">
            <div className="pageHeader__content">
              <h1 className="pageHeader__title">About Us</h1>

              <p className="pageHeader__text">
                A tropical paradise made for animal lovers replete with monkey
                caves, dog foundations, and dolphins in the wild.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
