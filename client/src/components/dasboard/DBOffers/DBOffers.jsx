import React, { useEffect, useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import Pagination from "../../common/Pagination";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import useToken from "@/hooks/useToken";
import AdminPanelLoader from "@/components/AdminPanelLoader";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";

export default function DBOffers() {
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [offers, setOffers] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { token } = useToken();
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  const handleAddClick = () => {
    navigate("add-offer");
  };

  useEffect(() => {
    if (token !== null) {
      if (!token) {
        toast.error("You need to log into your account first");
        navigate("/admin-login");
      } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
        toast.error("Your session has expired, please log in again");
        navigate("/admin-login");
      } else {
        fetch(`http://localhost:9092/data/admin/getOffers/${token}`, {
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
              setOffers(data?.message);
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

  function formatDateTime(dateTime) {
    const { year, month, day, hour, minute } = dateTime;
    const formattedMonth = String(month).padStart(2, '0');
    const formattedDay = String(day).padStart(2, '0');
    const formattedMinute = String(minute).padStart(2, '0');

    const formattedHour = hour % 12 || 12;
    const amPm = hour >= 12 ? 'PM' : 'AM';

    return `${year}-${formattedMonth}-${formattedDay} ${formattedHour}.${formattedMinute} ${amPm}`;
  }


  const filteredOffers = offers.filter((elm) =>
    elm.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const paginatedOffers = filteredOffers.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  return (
    <div
      className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""
        } js-dashboard`}
    >
      <Sidebar setSideBarOpen={setSideBarOpen} />

      <div className="dashboard__content">
        <Header setSideBarOpen={setSideBarOpen} />
        {loading ? (<>
          <AdminPanelLoader />
        </>) : (<>
          <div className="dashboard__content_content">
            <h1 className="text-30">Offers</h1>
            <p className="">Manage your travel offers and promotions to attract more travelers and enhance their experiences</p>

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
                      pointerEvents: "none",
                    }}
                  />
                  <input
                    type="search"
                    className="input -border-light-1"
                    placeholder="Search Offers..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={{
                      paddingLeft: "40px",
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
                      <th>Date</th>
                      <th>Location</th>
                      {/* <th>Destination</th> */}
                      <th>Action</th>
                    </tr>
                  </thead>

                  <tbody>
                    {paginatedOffers.length == 0 && <>
                      <tr>
                        <td colSpan="7" className="text-center h-50 ">
                          No offers available.
                        </td>
                      </tr>
                    </>}
                    {paginatedOffers && paginatedOffers
                      .filter((elm) =>
                        elm.title.toLowerCase().includes(searchTerm.toLowerCase())
                      )
                      .map((elm, i) => (
                        <tr key={elm.offer_id}>
                          <td>{(currentPage - 1) * itemsPerPage + i + 1}</td>
                          <td>
                            <img
                              src={`http://localhost:9091/${elm.image}`}
                              alt={elm.title}
                              style={{
                                width: "50px",
                                height: "50px",
                                borderRadius: "8px",
                              }}
                            />
                          </td>
                          <td>{elm.title}</td>
                          <td>{formatDateTime(elm.from_Date)} - {formatDateTime(elm.to_Date)}</td>
                          <td>{elm.location_title}</td>
                          {/* <td>{elm.destination_title}, {elm.country_name}</td> */}
                          <td>
                            <div className="d-flex items-center justify-center">
                              <button className="button -dark-1 size-35 bg-light-1 rounded-full flex-center" onClick={() => navigate('edit-offer', { state: { offer: elm } })}>
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
                totalItems={filteredOffers.length}
                itemsPerPage={itemsPerPage}
                currentPage={currentPage}
                onPageChange={handlePageChange}
              />

              <div className="text-14 text-center mt-20">
                Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredOffers.length)} of {offers.length}
              </div>
            </div>

            <div className="text-center pt-30">
              © Copyright QuickRoute {new Date().getFullYear()}
            </div>
          </div>
        </>)}
      </div>
    </div>
  );
}
