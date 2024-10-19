import React, { useState } from "react";
import Rating from '@mui/material/Rating';
import useToken from "@/hooks/useToken";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";

export default function CommentBox({ locationId }) {
  const [imagePreview, setImagePreview] = useState(null);
  const [image, setImage] = useState(null);
  const [comment, setComment] = useState("");
  const [starValue, setStarValue] = useState(0);



  const navigate = useNavigate()
  const handleImageChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      const validImageTypes = ["image/jpeg", "image/png"];
      if (!validImageTypes.includes(file.type)) {
        toast.error("Please upload a valid image file (JPEG or PNG)");
        return;
      }
      setImage(file);
      setImagePreview(URL.createObjectURL(file));
    }
  };
  const handleSubmit = () => {
    const token = localStorage.getItem('token')
    console.log(comment, starValue, image, token)
    if (token == null) {
      toast.error("You need to log into your account first");
      navigate("/login")
    } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
      toast.error("Your session has expired, please log in again");
      navigate("/login")
    } else if (starValue == 0) {
      toast.error("Please give a rating first");
    } else if (comment == "") {
      toast.error("Please write a comment");
    } else {
      const formData = new FormData()
      if (image != null) {
        formData.append('file', image)
      }
      formData.append('comment', comment)
      formData.append('rating', starValue)
      formData.append('email', decodeJWT(token).email)
      formData.append('locationId', locationId)
      fetch(`http://localhost:9093/clientData/user/rating/addLocationReview/${token}`, {
        method: 'POST',
        body: formData,
        credentials: 'include'
      })
        .then(response => {
          if (response.status === 401) {
            navigate('/login');
            toast.error("Session Expired.");
          }
          return response.json();
        })
        .then(data => {
          if (data.success) {
            toast.success("Review added successfully");
            window.location.reload()
          } else {
            toast.error(data.message);
          }
        })
        .catch(error => {
          toast.error(error.message);
        });
    }
  }
  return (
    <>
      <div className="d-flex justify-content-start">
        <h2 className="text-30 pt-0 ">Leave a Reply</h2>
      </div>

      <div className="reviewsGrid pt-30">

        <div className="reviewsGrid__item">

          <Rating name="size-medium" defaultValue={0} onChange={(event, newValue) => {
            setStarValue(newValue);
            console.log(newValue)
          }} />
        </div>

      </div>

      <div className="contactForm y-gap-30 pt-30">

        <div className="col-12">
          <div className="row x-gap-20 y-gap">
            {imagePreview ? (
              <div className="col-auto">
                <div className="relative">
                  <img
                    src={imagePreview}
                    alt="image"
                    className="size-130 rounded-12 object-cover"
                  />
                  <button
                    onClick={() => {
                      setImage(null);
                      setImagePreview(null)
                    }}
                    className="absoluteIcon1 button -dark-1"
                  >
                    <i className="icon-delete text-18"></i>
                  </button>
                </div>
              </div>
            ) : (
              <div className="col-auto">
                <label
                  htmlFor="imageInp1"
                  className="size-130 rounded-12 border-dash-1 bg-accent-1-05 flex-center flex-column"
                >
                  <img alt="image" src={"/img/dashboard/upload.svg"} />

                  <div className="text-4 fw-500 text-accent-1 mt-10">
                    Upload Images
                  </div>
                </label>
                <input
                  onChange={handleImageChange}
                  accept="image/*"
                  id="imageInp1"
                  type="file"
                  style={{ display: "none" }}
                />
              </div>
            )}
          </div>

          <div className="text-14 mt-10">
            PNG or JPG no bigger than 800px wide and tall.
          </div>
        </div>


        <div className="row">
          <div className="col-12">
            <div className="form-input ">
              <textarea value={comment} onChange={(e) => setComment(e.target.value)} required rows="5" placeholder="Comment"></textarea>
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
