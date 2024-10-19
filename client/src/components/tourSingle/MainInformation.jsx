import React, { useState } from "react";
import Stars from "../common/Stars";
import AddToPlanPopover from "../common/AddToPlanPopover";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";

export default function MainInformation({ tour,id }) {
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedTour, setSelectedTour] = useState(null);
  const navigate = useNavigate()

  const handleOpenPopover = (event, elm) => {
    setAnchorEl(event.currentTarget);
    setSelectedTour(elm);
  };

  const handleClosePopover = () => {
    setAnchorEl(null);
    setSelectedTour(null);
  };
  return (
    <>
      <div className="row y-gap-20 justify-between items-end">
        {/* Left aligned section */}
        <div className="col-auto">
          <h2 className="text-40 sm:text-30 lh-14 mt-20">
            {tour?.title}
          </h2>
        </div>

        <div className="row x-gap-20  y-gap-20 items-center pt-20 justify-between flex-grow-1">
          <div className="col-auto d-flex items-center x-gap-15">
            {tour?.total_ratings == 0 ? (<span>No reviews</span>) : (
              <>
                <div className="d-flex x-gap-5 pr-10">
                  <Stars star={tour?.average_rating} font={12} black={true} />
                </div>
                <span>{tour?.rating}({tour?.total_ratings})</span>
              </>
            )}

            <div className="d-flex items-center x-gap-5 mx-10">
              <i className="icon-pin text-16 mr-5"></i>
              <span>{tour?.destination_title}, {tour?.country_name}</span>
            </div>
          </div>

          <div className="col-auto ml-auto">
            <div className="d-flex x-gap-30 y-gap-10">
              <button onClick={(e) => handleOpenPopover(e, "mk")} className="d-flex items-center">
                <i className="icon-plus flex-center text-16 mr-10"></i>
                Add to Plan
              </button>

              <button className="d-flex items-center" onClick={() => {
                navigator.clipboard.writeText(window.location.href)
                  .then(() => {
                    toast.success('Link copied to clipboard!');
                  })
                  .catch(err => {
                    toast.error('Failed to copy: ', err.message);
                  });
              }}>
                <i className="icon-share flex-center text-16 mr-10"></i>
                Share
              </button>

              <button onClick={() => {
                const location_id = tour.location_id
                var token = localStorage.getItem("token");
                if (token == null) {
                  toast.error("You need to log into your account first");
                  navigate("/login")
                } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
                  toast.error("Your session has expired, please log in again");
                  navigate("/login")
                } else {
                  fetch(`http://localhost:9093/clientData/user/wishlist/add/${token}?destinations_id=${location_id}`)
                    .then((data) => {
                      if (data.ok) {
                        return data.json();
                      } else {
                        toast.error("Failed to fetch wishlist");
                      }
                    })
                    .then((response) => {
                      if (response.success) {
                        toast.success("Added to wishlist");
                      } else {
                        toast.error("Failed to add to wishlist");
                      }
                    })
                    .catch((error => console.log(error)))
                }
              }} className="d-flex items-center">
                <i className="icon-heart flex-center text-16 mr-10"></i>
                Wishlist
              </button>
            </div>
          </div>
        </div>
      </div>
      {selectedTour && (
        <AddToPlanPopover
          anchorEl={anchorEl}
          handleClose={handleClosePopover}
          elm={selectedTour}
          destinations_id={id}
        />
      )}
    </>
  );
}
