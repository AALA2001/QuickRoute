import React from "react";
import { useNavigate } from "react-router-dom";

export default function SingleThree({ data }) {
  const navigate = useNavigate()
  return (
    <section className="pt-30 js-pin-container">
      <div className="container">
        <div className="row y-gap-30 justify-between">
          <div className="col-lg-12">
            <div className="row">
              {/* card */}
              {data?.map((item, index) => {
                const itinerary = item?.itinerary || [];
                return (
                  <div className="col-md-6" style={{ marginBottom: 200 }} key={index}>
                    <div className="shadow-1 border-1 p-5 rounded-20" style={{ height: "650px", width: "500px" }}>
                      <h2 className="text-30">Itinerary {index + 1}</h2>
                      <div className="mt-30">
                        <div className="roadmap" style={{ overflow: "scroll", height: "350px" }}>
                          {itinerary.map((dayItem, dayIndex) => {
                            const isFirstDay = dayIndex === 0;
                            const isLastDay = dayIndex === itinerary.length - 1;
                            return (
                              <div className="roadmap__item" style={{ width: "100%" }} key={dayIndex}>
                                <div className={`roadmap__icon${isFirstDay || isLastDay ? 'Big' : ''}`}>
                                  {isFirstDay && <i className="icon-pin"></i>}
                                  {isLastDay && !isFirstDay && <i className="icon-flag"></i>}
                                </div>
                                <div className="roadmap__wrap">
                                  <div className="roadmap__title">{dayItem.day}: {dayItem.title}</div>
                                  {dayItem.description && (
                                    <div className="d-flex align-items-center">
                                      <span className="bullet-point"></span>
                                      {dayItem.description}
                                    </div>
                                  )}
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      </div>
                      <div className="line mt-50 mb-50"></div>
                      <div className="d-flex justify-content-center">
                        <button onClick={() => navigate('/invoice', { state: { plan: item, index: index } })}
                          className="button -dark-1 p-3 bg-accent-1 text-20 rounded-5 text-white"
                          style={{ width: "200px" }}
                        >
                          View Plan
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
