import React, { useEffect, useState } from "react";
import Sidebar from "../Sidebar";
import States from "./States";
import Activities from "./Activities";
import Statistics from "./Statistics";
import Header from "../Header";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";
import useToken from "@/hooks/useToken";
import AdminPanelLoader from "@/components/AdminPanelLoader";

export default function DBMain() {
  const navigate = useNavigate()
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [loading, setLoading] = useState(true);
  const { token } = useToken()
  useEffect(() => {
    if (token !== null) {
      if (token == null) {
        toast.error("You need to log into your account first");
        navigate("/admin-login")
      } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
        toast.error("Your session has expired, please log in again");
        navigate("/admin-login")
      }
    }
  }, [token]);

  const [count, setCount] = useState([]);
  useEffect(() => {
    if (token) {
      fetch(`http://localhost:9092/data/admin/getTotalCounts/${token}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
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
          setLoading(false)
          if (data.success) {
            setCount(data.message)
          } else {
            toast.error(data.message)
          }
        })
        .catch(error => {
          setLoading(false)
          toast.error(error.message)
        })
    }
  }, [token])

  return (
    <>
      <div
        className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""
          } js-dashboard`}
      >
        <Sidebar setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content">
          <Header setSideBarOpen={setSideBarOpen} />

          <div className="dashboard__content_content">
            {loading ? (<>
              <AdminPanelLoader />
            </>) : (<>
              <h1 className="text-30">Dashboard</h1>
              <p className="">QuickRoute, Your Itinerary Generator</p>

              <States count={count} />

              <div className="row pt-30 y-gap-30">
                <Statistics list={count.stats}/>

                <div className="col-xl-4 col-lg-12 col-md-6">
                  <div className="px-30 py-25 rounded-12 bg-white shadow-2">
                    <div className="d-flex items-center justify-between">
                      <div className="text-18 fw-500">Recent Reviews</div>
                    </div>

                    <Activities list={count.reviewsList} />

                    <div className="pt-40">
                      <button onClick={() => navigate('/admin/reviews')} className="button -md -outline-accent-1 col-12 text-accent-1">
                        View More
                        <i className="icon-arrow-top-right text-16 ml-10"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div className="text-center pt-30">
                © Copyright QuickRoute {new Date().getFullYear()}
              </div>
            </>)}
          </div>
        </div>
      </div>
    </>
  );
}
