import React, { useEffect, useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import { useLocation } from "react-router-dom";
import Reviews from "./Reviews";
import useToken from "@/hooks/useToken";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";

export default function LocationReviews() {
  const location = useLocation();
  const location_id = location.state?.locationId;

  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [reviews, setReviews] = useState([]);

  const { token } = useToken()

  useEffect(() => {
    if (token !== null) {
      if (!token) {
        toast.error("You need to log into your account first");
        navigate("/admin-login");
      } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
        toast.error("Your session has expired, please log in again");
        navigate("/admin-login");
      } else {
        fetch(`http://localhost:9092/data/admin/getLocationReviews/${token}?locationId=${location_id}`, {
          method: "GET",
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include'
        })
          .then((response) => {
            if (response.status === 401) {
              navigate('/admin-login');
              toast.error("Session Expired.");
            }
            return response.json();
          })
          .then((data) => {
            if (data.success) {
              setReviews(data.message)
            } else {
              toast.error(data.message)
            }
          })
          .catch((error) => {
            toast.error(error.message)
          });
      }
    }
  }, [token])

  return (
    <div
      className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""
        } js-dashboard`}
    >
      <Sidebar setSideBarOpen={setSideBarOpen} />

      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content_content">
          <h1 className="text-30">Customer Reviews</h1>
          <p className="">Browse and manage location reviews to maintain quality and ensure valuable feedback from travelers</p>

          <div className="contactForm row y-gap-30 rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">
            <Reviews reviews={reviews} />

          </div>

          <div className="text-center pt-30">
            © Copyright QuickRoute {new Date().getFullYear()}
          </div>
        </div>
      </div>
    </div>
  );
}
