import React, { useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import { useLocation, useNavigate } from "react-router-dom";
import SelectWithSearchLocation from "./SelectWithSearchLocation";
import useToken from "@/hooks/useToken";
import toast from "react-hot-toast";

export default function AddOffer() {
  const navigate = useNavigate();
  const location = useLocation();
  const offer = location.state?.offer;
  const { token } = useToken()

  const formatDateTimeLocal = (dateObject) => {
    if (!dateObject || !dateObject.year || !dateObject.month || !dateObject.day || !dateObject.hour || !dateObject.minute) {
      return "";
    }
    const year = dateObject.year.toString().padStart(4, '0');
    const month = dateObject.month.toString().padStart(2, '0');
    const day = dateObject.day.toString().padStart(2, '0');
    const hour = dateObject.hour.toString().padStart(2, '0');
    const minute = dateObject.minute.toString().padStart(2, '0');

    return `${year}-${month}-${day}T${hour}:${minute}`;
  };

  const convertToDateTime = (dateTimeString) => {
    const [datePart, timePart] = dateTimeString.split('T');
    const formattedTime = `${timePart}:59`;
    return `${datePart} ${formattedTime}`;
  };

  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [title, setTitle] = useState(offer?.title || "");
  const [from, setFrom] = useState(formatDateTimeLocal(offer?.from_Date) || "");
  const [to, setTo] = useState(formatDateTimeLocal(offer?.to_Date) || "");
  const [imagePreview, setImagePreview] = useState(offer ? `http://localhost:9091/${offer.image}` : null);
  const [image, setImage] = useState("");
  const [desLocation, setDesLocation] = useState(offer?.location_title || "");
  const [resetDropdown, setResetDropdown] = useState(false);

  const handleAddClick = () => {
    if (desLocation == "") {
      toast.error("Please select a destination location");
    } else if (title == "") {
      toast.error("Please enter a title");
    } else if (from == "") {
      toast.error("Please enter a offer start date");
    } else if (to == "") {
      toast.error("Please enter a offer end date");
    } else if (image == "") {
      toast.error("Please upload an image");
    } else if (title.length > 100) {
      toast.error("Title should not be more than 100 characters");
    } else if (image == null) {
      toast.error("Please upload an image");
    } else {
      const formData = new FormData();
      formData.append('destinationLocationId', desLocation);
      formData.append('fromDate', convertToDateTime(from));
      formData.append('toDate', convertToDateTime(to));
      formData.append('title', title);
      formData.append('file', image);
      fetch(`http://localhost:9092/data/admin/addOffer/${token}`, {
        method: 'POST',
        body: formData,
        credentials: 'include'
      })
        .then((response) => {
          if (response.status == 401) {
            navigate('/admin-login');
            toast.error("Session Expired.");
          }
          return response.json();
        })
        .then((data) => {
          console.log(data)
          if (data.success) {
            toast.success(data.message);
          } else {
            toast.error(data.message);
          }
          handleClearClick()
          navigate('/admin/offers')
        })
        .catch((error) => {
          toast.error(error.message);
        })
    }
  };

  const handleFocus = (e) => {
    e.target.type = "datetime-local";
  };

  const handleBlur = (e) => {
    if (!from) {
      e.target.type = "text";
    }
  };

  const handleClearClick = () => {
    setTitle("");
    setDesLocation("");
    setFrom(null);
    setTo("");
    setImage(null);
    setImagePreview(null);
    setResetDropdown(true)
    setTimeout(() => setResetDropdown(false), 0);
  };

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

  const handleUpdateClick = () => {
    const formData = new FormData();
    formData.append('offerId', offer.offer_id)
    let isModified = false;

    if (desLocation !== offer.location_title) {
      console.log(desLocation)
      console.log(offer.location_title)
      formData.append('locationId', desLocation);
      isModified = true;
    }

    if (title !== offer.title) {
      formData.append('title', title);
      isModified = true;
    }

    if (from !== formatDateTimeLocal(offer.from_Date)) {
      formData.append('fromDate', convertToDateTime(from));
      isModified = true;
    }

    if (to !== formatDateTimeLocal(offer.to_Date)) {
      formData.append('toDate', convertToDateTime(to));
      isModified = true;
    }

    if (image) {
      formData.append('file', image);
      isModified = true;
    }

    if (!isModified) {
      toast.error("No changes detected");
      return;
    }

    if (token) {
      fetch(`http://localhost:9092/data/admin/updateOffer/${token}`, {
        method: 'PUT',
        body: formData,
        credentials: 'include',
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
            toast.success(data.message);
          } else {
            toast.error(data.message);
          }
          handleClearClick();
          navigate('/admin/offers')
        })
        .catch((error) => {
          toast.error(error.message);
        });

    }
  };

  return (
    <div
      className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""
        } js-dashboard`}
    >
      <Sidebar setSideBarOpen={setSideBarOpen} />

      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content_content">
          <h1 className="text-30">{offer ? 'Edit' : 'Add New'} Offer</h1>
          <p className="">Create a New Offer. Add details and discounts to provide exciting travel deals for your customers</p>

          <div className="contactForm row y-gap-30 rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">
            <div className="col-12">
              <div className="form-input ">
                <SelectWithSearchLocation onSelect={(id) => setDesLocation(id)} selected={desLocation} reset={resetDropdown} />
              </div>
            </div>

            <div className="col-12">
              <div className="form-input">
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  className={title ? "not-empty" : ""}
                />
                <label className="lh-1 text-16 text-light-1">Title</label>
              </div>
            </div>

            {/* From Field */}
            <div className="col-12">
              <div className="form-input">
                <input
                  type={offer ? "datetime-local" : "text"}
                  placeholder=" "
                  value={from}
                  onChange={(e) => setFrom(e.target.value)}
                  onFocus={handleFocus}
                  onBlur={handleBlur}
                  required
                  className={from ? "not-empty" : ""}
                />
                <label className="lh-1 text-16 text-light-1">From</label>
              </div>
            </div>

            <div className="col-12">
              <div className="form-input">
                <input
                  type={offer ? "datetime-local" : "text"}
                  placeholder=" "
                  value={to}
                  onChange={(e) => setTo(e.target.value)}
                  onFocus={handleFocus}
                  onBlur={handleBlur}
                  required
                  className={to ? "not-empty" : ""}
                />
                <label className="lh-1 text-16 text-light-1">To</label>
              </div>
            </div>
            {/* Image Upload Field */}
            <div className="col-12">
              <h4 className="text-18 fw-500 mb-20">Add Location Image</h4>
              <div className="row x-gap-20 y-gap">
                {imagePreview ? (
                  <div className="col-auto">
                    <div className="relative">
                      <img
                        src={imagePreview}
                        alt="image"
                        className="size-200 rounded-12 object-cover"
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
                      className="size-200 rounded-12 border-dash-1 bg-accent-1-05 flex-center flex-column"
                    >
                      <img alt="image" src={"/img/dashboard/upload.svg"} />

                      <div className="text-16 fw-500 text-accent-1 mt-10">
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

            {/* Action Buttons */}
            <div className="col-12 d-flex justify-end ">
              <button
                className="button -md -outline-dark-1 mr-20 text-dark-1 h-50"
                onClick={handleClearClick}
              >
                Clear
              </button>
              {
                offer ? (<>
                  <button
                    className="button -md -dark-1 bg-accent-1 text-white h-50"
                    onClick={handleUpdateClick}
                  >
                    Update
                  </button>
                </>) : (<>
                  <button
                    className="button -md -dark-1 bg-accent-1 text-white h-50"
                    onClick={handleAddClick}
                  >
                    Add
                  </button>
                </>)
              }

            </div>
          </div>

          <div className="text-center pt-30">
            © Copyright QuickRoute {new Date().getFullYear()}
          </div>
        </div>
      </div>
    </div>
  );
}
