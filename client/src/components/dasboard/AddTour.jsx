import React, { useState } from "react";
import Sidebar from "./Sidebar";
import Header from "../Header";
import Pagination from "../../common/Pagination";
import { destinationsData } from "@/data/destinationsData";
import { useNavigate } from "react-router-dom";

export default function DBDestinations() {
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();

  const handleAddClick = () => {
    navigate("add-destination"); // Navigate to the new page
  }; 

  return (
    <div
      className={`dashboard ${
        sideBarOpen ? "-is-sidebar-visible" : ""
      } js-dashboard`}
    >
      <Sidebar setSideBarOpen={setSideBarOpen} />

      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content_content">
          <h1 className="text-30">Destinations</h1>
          <p className="">Manage your travel destinations below.</p>

          <div className="rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">
            <div className="d-flex justify-end align-center mb-8 dbSearch">
              <div
                className="d-flex items-center mr-20 search-container"
                style={{ position: "relative", maxWidth: "300px" }}
              >
                <i
                  className="icon-search text-16 ml-5"
                  style={{
                    position: "absolute",
                    left: "10px",
                    top: "50%",
                    transform: "translateY(-50%)",
                    pointerEvents: "none", // Makes sure the icon doesn't interfere with input focus
                  }}
                />
                <input
                  type="search"
                  className="input -border-light-1"
                  placeholder="Search destinations..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  style={{
                    paddingLeft: "40px", // Adds space for the icon
                  }}
                />
              </div>

              <button
                className="button -md -dark-1 bg-accent-1 text-white h-50"
                onClick={handleAddClick}
              >
                Add
              </button>
            </div>

            <div className="overflowAuto">
              <table className="tableTest mb-30">
                <thead className="bg-light-1 rounded-12">
                  <tr>
                    <th>ID</th>
                    <th>Image</th>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Country</th>
                    <th>Action</th>
                  </tr>
                </thead>

                <tbody>
                  {destinationsData
                    .filter((elm) =>
                      elm.title.toLowerCase().includes(searchTerm.toLowerCase())
                    )
                    .map((elm, i) => (
                      <tr key={i}>
                        <td>{elm.id}</td>
                        <td>
                          <img
                            src={elm.imageUrl}
                            alt={elm.title}
                            style={{
                              width: "50px",
                              height: "50px",
                              borderRadius: "8px",
                            }}
                          />
                        </td>
                        <td>{elm.title}</td>
                        <td className="min-w-300">{elm.description}</td>
                        <td>{elm.country}</td>
                        <td>
                          <div className="d-flex items-center justify-center">
                            <button className="button -dark-1 size-35 bg-light-1 rounded-full flex-center">
                              <i className="icon-pencil text-14"></i>
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>

            <Pagination />

            <div className="text-14 text-center mt-20">
              Showing results 1-30 of {destinationsData.length}
            </div>
          </div>

          <div className="text-center pt-30">
            © Copyright Viatours {new Date().getFullYear()}
          </div>
        </div>
      </div>
    </div>
  );
}
