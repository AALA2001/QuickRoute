import React, { useEffect, useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import Pagination from "../../common/Pagination";
import { useNavigate } from "react-router-dom";
import useToken from "@/hooks/useToken";
import { toast } from "react-hot-toast";
import AdminPanelLoader from "@/components/AdminPanelLoader";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";

export default function DBLocations() {
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [locations, setLocations] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const { token } = useToken();

  useEffect(() => {
    if (token !== null) {
      if (!token) {
        toast.error("You need to log into your account first");
        navigate("/admin-login");
      } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
        toast.error("Your session has expired, please log in again");
        navigate("/admin-login");
      } else {
        fetch(`http://localhost:9092/data/admin/getLocations/${token}`, {
          method: "GET",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
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
            if (data?.success) {
              setLocations(data?.message);
            } else {
              toast.error(data?.message);
            }
          })
          .catch((error) => {
            setLoading(false)
            toast.error(error.message);
          });
      }
    }
  }, [token]);

  const filteredLocations = locations.filter((elm) =>
    elm.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const paginatedLocations = filteredLocations.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handleAddClick = () => {
    navigate("add-location");
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };
  return (
    <div className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""} js-dashboard`}>
      <Sidebar setSideBarOpen={setSideBarOpen} />
      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />
        {loading ? (<><AdminPanelLoader /></>) : (
          <div className="dashboard__content_content">
            <h1 className="text-30">Locations</h1>
            <p>Manage and organize your locations below to ensure accurate and up-to-date information for travelers</p>

            <div className="rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 md:px-20 md:pt-20 md:mb-20 mt-60">
              <div className="d-flex justify-end align-center mb-8 dbSearch">
                <div className="d-flex items-center mr-20 search-container" style={{ position: "relative", maxWidth: "300px" }}>
                  <i className="icon-search text-16 ml-5" style={{
                    position: "absolute",
                    left: "10px",
                    top: "50%",
                    transform: "translateY(-50%)",
                    pointerEvents: "none",
                  }} />
                  <input
                    type="search"
                    className="input -border-light-1"
                    placeholder="Search locations..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={{ paddingLeft: "40px" }}
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
                      <th>Tour Type</th>
                      <th>Action</th>
                    </tr>
                  </thead>

                  <tbody>
                    {paginatedLocations.length == 0 && <>
                      <tr>
                        <td colSpan="7" className="text-center h-50 ">
                          No locations available.
                        </td>
                      </tr>
                    </>}
                    {paginatedLocations && paginatedLocations.map((elm, i) => (
                      <tr key={elm.location_id}>
                        <td>{(currentPage - 1) * itemsPerPage + i + 1}</td>
                        <td>
                          <img
                            src={`http://localhost:9091/${elm.image}`}
                            alt={elm.title}
                            style={{ width: "50px", height: "50px", borderRadius: "8px" }}
                          />
                        </td>
                        <td>{elm.title}</td>
                        <td className="min-w-auto">{elm.overview.length > 80
                          ? `${elm.overview.substring(0, 80)}...`
                          : elm.overview}</td>
                        <td>{elm.destination_title}, {elm.country_name}</td>
                        <td>{elm.tour_type}</td>
                        <td>
                          <div className="d-flex items-center justify-center">
                            <button onClick={() => navigate('location-reviews', { state: { locationId: elm.location_id } })} className="button mr-5 -dark-1 size-35 bg-light-1 rounded-full flex-center">
                              <i className="icon-review text-14"></i>
                            </button>
                            <button onClick={() => navigate('edit-location', { state: { desLocation: elm } })} className="button -dark-1 size-35 bg-light-1 rounded-full flex-center">
                              <i className="icon-pencil text-14"></i>
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <Pagination
                totalItems={filteredLocations.length}
                itemsPerPage={itemsPerPage}
                currentPage={currentPage}
                onPageChange={handlePageChange}
              />
              <div className="text-14 text-center mt-20">
                Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredLocations.length)} of {filteredLocations.length}
              </div>
            </div>

            <div className="text-center pt-30">
              © Copyright QuickRoute {new Date().getFullYear()}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
