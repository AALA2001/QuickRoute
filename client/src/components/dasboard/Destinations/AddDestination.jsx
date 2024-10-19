import React, { useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import { useLocation, useNavigate } from "react-router-dom";
import SelectWithSearchCountry from "../SelectWithSearchCountry";
import useToken from "@/hooks/useToken";
import toast from "react-hot-toast";

export default function AddDestination() {
  const navigate = useNavigate();
  const location = useLocation();
  const destination = location.state?.destination;

  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [title, setTitle] = useState(destination?.title || "");
  const [description, setDescription] = useState(destination?.description || "");
  const [country, setCountry] = useState(destination?.country_name || null);
  const [image, setImage] = useState(null);
  const { token } = useToken()
  const [imagePreview, setImagePreview] = useState(destination ? `http://localhost:9091/${destination.image}` : null);
  const [resetDropdown, setResetDropdown] = useState(false);


  const handleAddClick = () => {
    if (country == "") {
      toast.error("Please select a country");
    } else if (title == "") {
      toast.error("Please enter a title");
    } else if (description == "") {
      toast.error("Please enter a description");
    } else if (image == "") {
      toast.error("Please upload an image");
    } else if (title.length > 100) {
      toast.error("Title should not be more than 100 characters");
    } else if (image == null) {
      toast.error("Please upload an image");
    } else {
      const formData = new FormData();
      formData.append('title', title);
      formData.append('description', description);
      formData.append('country_id', country);
      formData.append('file', image);
      fetch(`http://localhost:9092/data/admin/addDestination/${token}`, {
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
          navigate('/admin/destinations')
        })
        .catch((error) => {
          toast.error(error.message);
        })
    }
  };

  const handleClearClick = () => {
    setTitle("");
    setDescription("");
    setCountry(0);
    setImage(null);
    setImagePreview(null);
    setResetDropdown(true)
    setTimeout(() => setResetDropdown(false), 0);
  };

  const handleUpdateClick = () => {
    const formData = new FormData();
    formData.append('destinationId', destination.destination_id)
    let isModified = false;

    if (title !== destination.title) {
      formData.append('title', title);
      isModified = true;
    }

    if (description !== destination.description) {
      formData.append('description', description);
      isModified = true;
    }

    if (country !== destination.country_name) {
      formData.append('country_id', country);
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

    fetch(`http://localhost:9092/data/admin/updateDestination/${token}`, {
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
        navigate('/admin/destinations')
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
          <h1 className="text-30"> {destination ? 'Edit' : 'Add'} New Destination</h1>
          <p className="">Add New Travel Destinations Here. Enter details to expand your travel offerings and inspire more adventures</p>

          <div className="contactForm row y-gap-30 rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">
            {/* Country Dropdown */}
            <div className="col-12">
              <div className="form-input ">
                <SelectWithSearchCountry onSelect={(id) => setCountry(id)} selected={country} reset={resetDropdown} />
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


            {/* Tour Content Field */}
            <div className="col-12">
              <div className="form-input ">
                <textarea
                  placeholder="Description"
                  required
                  rows="4"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className={description ? "not-empty" : ""}
                ></textarea>
              </div>
            </div>
            {/* Image Upload Field */}
            <div className="col-12">
              <h4 className="text-18 fw-500 mb-20">Add Destination Image</h4>
              <div className="row x-gap-20 y-gap">
                {imagePreview ? (
                  <div className="col-auto">
                    <div className="relative">
                      <img
                        src={imagePreview}
                        alt="Uploaded"
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

              {destination ? (
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
