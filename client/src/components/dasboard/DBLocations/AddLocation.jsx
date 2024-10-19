import React, { useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import { useLocation, useNavigate } from "react-router-dom";
import SelectWithSearchDestination from "./SelectWithSearchDestination";
import useToken from "@/hooks/useToken";
import toast from "react-hot-toast";
import SelectWithSearchTourType from "../SelectWithSearchTourType";

export default function AddLocation() {
  const navigate = useNavigate();
  const location = useLocation();
  const desLocation = location.state?.desLocation;

  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [title, setTitle] = useState(desLocation?.title || "");
  const [overview, setOverview] = useState(desLocation?.overview || "");
  const [tourType, setTourType] = useState(desLocation?.tour_type || "");
  const [destination, setDestination] = useState(desLocation?.destination_title || "");
  const [image, setImage] = useState("");
  const [imagePreview, setImagePreview] = useState(desLocation ? `http://localhost:9091/${desLocation.image}` : null);
  const [resetDropdown, setResetDropdown] = useState(false);

  const { token } = useToken();

  const handleAddClick = () => {
    if (destination == "") {
      toast.error("Please select a destination");
    } else if (tourType == "") {
      toast.error("Please select a tour type");
    } else if (title == "") {
      toast.error("Please enter a title");
    } else if (overview == "") {
      toast.error("Please enter a overview");
    } else if (image == "") {
      toast.error("Please upload an image");
    } else if (title.length > 100) {
      toast.error("Title should not be more than 100 characters");
    } else if (image == null) {
      toast.error("Please upload an image");
    } else {
      const formData = new FormData();
      formData.append('destinationId', destination);
      formData.append('tourTypeId', tourType);
      formData.append('title', title);
      formData.append('overview', overview);
      formData.append('file', image);
      fetch(`http://localhost:9092/data/admin/addLocation/${token}`, {
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
          navigate('/admin/locations')
        })
        .catch((error) => {
          toast.error(error.message);
        })
    }
  };

  const handleClearClick = () => {
    setTitle("");
    setOverview("");
    setTourType(0);
    setDestination(0);
    setImage(null);
    setImagePreview(null);
    setResetDropdown(true)
    setTimeout(() => setResetDropdown(false), 0);
  };

  const handleUpdateClick = () => {
    const formData = new FormData();
    formData.append('locationId', desLocation.location_id)
    let isModified = false;

    if (title !== desLocation.title) {
      formData.append('title', title);
      isModified = true;
    }

    if (overview !== desLocation.overview) {
      formData.append('overview', overview);
      isModified = true;
    }

    if (tourType !== desLocation.tour_type) {
      formData.append('tourTypeId', tourType);
      isModified = true;
    }

    if (destination !== desLocation.destination_title) {
      formData.append('destinationId', destination);
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

    fetch(`http://localhost:9092/data/admin/updateLocation/${token}`, {
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
        navigate('/admin/locations')
      })
      .catch((error) => {
        toast.error(error.message);
      });

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

  return (
    <div
      className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""
        } js-dashboard`}
    >
      <Sidebar setSideBarOpen={setSideBarOpen} />

      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content_content">
          <h1 className="text-30"> {desLocation ? 'Edit' : 'Add New'} Location</h1>
          <p className="">Add a New Location. Provide details to expand your destination offerings and enhance the travel experience.</p>

          <div className="contactForm row y-gap-30 rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">

            <div className="col-12">
              <div className="form-input ">
                <SelectWithSearchDestination onSelect={(id) => setDestination(id)} selected={destination} reset={resetDropdown} />
              </div>
            </div>

            <div className="col-12">
              <div className="form-input ">
                <SelectWithSearchTourType onSelect={(id) => setTourType(id)} selected={tourType} reset={resetDropdown} />
              </div>
            </div>

            {/* Title Field */}
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

            <div className="col-12">
              <div className="form-input ">
                <textarea
                  placeholder="Location Overview"
                  required
                  rows="8"
                  value={overview}
                  onChange={(e) => setOverview(e.target.value)}
                  className={overview ? "not-empty" : ""}
                ></textarea>
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
              {desLocation ? (
                <button
                  className="button -md -dark-1 bg-accent-1 text-white h-50"
                  onClick={handleUpdateClick}
                >
                  Update
                </button>
              ) : (
                <button
                  className="button -md -dark-1 bg-accent-1 text-white h-50"
                  onClick={handleAddClick}
                >
                  Add
                </button>
              )}
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
