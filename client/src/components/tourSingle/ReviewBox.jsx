import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import React, { useState } from "react";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";

export default function ReviewBox() {
  const [comment, setComment] = useState("");
  const navigate = useNavigate()

  const handleSubmit = () => {
    var token = localStorage.getItem("token");
    if (token == null) {
      toast.error("You need to log into your account first");
      navigate("/login")
    } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
      toast.error("Your session has expired, please log in again");
      navigate("/login")
    } else if (comment == "") {
      toast.error("Please enter a comment");
    } else {
      fetch(`http://localhost:9093/clientData/site/review/${token}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          review: comment
        }),
        credentials: 'include'
      })
        .then((data) => {
          if (data.status == 401) {
            toast.error("Unauthorized. Please log in");
            navigate('/login')
          }
          return data.json();
        })
        .then((response) => {
          if (response.success) {
            toast.success("Successfully added your review");
            navigate("/")
          } else {
            toast.error("Failed to add a review");
          }
        })
        .catch((error => console.log(error)))
    }
  }

  return (
    <>
      <div className="d-flex justify-content-start">
        <h2 className="text-30 pt-0 ">Leave a Reply</h2>
      </div>

      <div className="contactForm y-gap-30 pt-30">
        <div className="row">
          <div className="col-12">
            <div className="form-input ">
              <textarea value={comment} onChange={(e) => setComment(e.target.value)} required rows="8" placeholder="Comment"></textarea>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col-12 d-flex justify-content-start ">
            <button className="button -md -dark-1 bg-accent-1 text-white" onClick={handleSubmit}>
              Post Review
              <i className="icon-arrow-top-right text-16 ml-10"></i>
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
