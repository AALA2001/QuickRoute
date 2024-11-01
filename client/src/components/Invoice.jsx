import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import React, { useState } from "react";
import toast from "react-hot-toast";
import { Link, useLocation, useNavigate } from "react-router-dom";



export default function Invoice() {
  const location = useLocation();
  const roadMap = location?.state?.plan?.itinerary;
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const handlePrintClick = () => {
    var token = localStorage.getItem("token");
    if (token == null) {
      toast.error("You need to log into your account first");
      navigate("/login")
    } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
      toast.error("Your session has expired, please log in again");
      navigate("/login")
    } else {
      setLoading(true)
      fetch(`http://localhost:9093/clientData/user/sendEmail/${token}`, {
        method: 'GET',
      })
        .then((data) => {
          if (data.ok) {
            return data.json();
          } else {
            toast.error("Failed to fetch data");
          }
        })
        .then((response) => {
          if (response.success) {
            toast.success("Itinerary generated successfully");
            window.print();
            navigate('/')
          }
          setLoading(false)
        }).catch((error => console.log(error))).finally(() => {
          setLoading(false)
        })
    }
  };
  return (
    <section className="layout-pt-lg layout-pb-lg bg-accent-1-05">
      <div className="container" style={{ maxWidth: "70%", margin: "0 auto" }}>
        <div className="row justify-center">
          <div className="col-xl-10 col-lg-11">
            <div className="d-flex justify-end" style={{ width: '70%', marginLeft: '14%' }}>
              <button
                onClick={handlePrintClick}
                className="button -md -dark-1 bg-accent-1 text-white text-18"
              >
                Save and Print
                <i className="icon-print text-20 ml-10"></i>
              </button>
            </div>

            <div className="bg-white rounded-4 mt-25" style={{ width: '70%', marginLeft: '14%' }}>
              <div className="layout-pt-lg layout-pb-lg px-50 md:px-20">
                <div className="row justify-between">
                  <div className="col-auto">
                    <Link to="/">
                      <img className="" src="/img/logo/2.png" width={250} alt="Logo" />
                    </Link>
                  </div>
                </div>

                <div className="row justify-between pt-50">
                  <div className="col-auto text-center">
                    <div className="text-20 fw-600">Plan Name</div>
                  </div>
                </div>

                <div className="d-flex justify-content-center pt-0">
                  <div className="row justify-center pt-20" style={{ width: "100%" }}>
                    {roadMap?.map((dayItem, dayIndex) => {
                      const isFirstDay = dayIndex === 0;
                      const isLastDay = dayIndex === roadMap.length - 1;
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
              </div>

              <div className="border-1-top py-40">
                <div className="row x-gap-60 y-gap-10 justify-center">
                  <div className="col-auto">
                    <a href="mailto:hello@quickroute.com" className="text-14">
                      hello@quickroute.com
                    </a>
                  </div>
                  <div className="col-auto">
                    <span className="text-14">Copyright at QuickRoute</span>
                  </div>
                  <div className="col-auto">
                    <a href="tel:+94713344556" className="text-14">
                      +94 71 334 4556
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}