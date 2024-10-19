import React from "react";

export default function Hero({ destination = {} }) {
  console.log(destination)
  return (
    <section className="pageHeader -type-1">
      <div className="pageHeader__bg">
        <img src={`http://localhost:9091/${destination?.image}`} alt="image" />
        <img src="/img/hero/1/shape.svg" alt="image" />
      </div>

      <div className="container">
        <div className="row justify-center">
          <div className="col-12">
            <div className="pageHeader__content">
              <h1 className="pageHeader__title">{destination?.title}</h1>

              <p className="pageHeader__text">
                {destination?.description}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
