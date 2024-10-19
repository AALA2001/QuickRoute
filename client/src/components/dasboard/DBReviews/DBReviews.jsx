import React, { useEffect, useState } from "react";
import Sidebar from "../Sidebar";
import Header from "../Header";
import Pagination from "../../common/Pagination";
import { destinationsData } from "@/data/destinationsData";
import { useNavigate } from "react-router-dom";
import useToken from "@/hooks/useToken";
import AdminPanelLoader from "@/components/AdminPanelLoader";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";

export default function DBReviews() {
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [hoveredReview, setHoveredReview] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const [popoverPosition, setPopoverPosition] = useState({ top: 0, left: 0 });
  const navigate = useNavigate();
  const { token } = useToken()

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const handleMouseEnter = (e, review) => {
    setHoveredReview(review);
    setPopoverPosition({
      top: e.clientY + 10,
      left: e.clientX + 10,
    });
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
        fetch(`http://localhost:9092/data/admin/getReviews/${token}`, {
          method: "GET",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
        })
          .then((response) => {
            if (response.status == 401) {
              navigate('/admin-login');
              toast.error("Session Expired.");
            }
            return response.json()
          })
          .then((data) => {
            setLoading(false)
            if (data?.success) {
              setReviews(data?.message);
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

  const filteredReviews = reviews.filter((elm) =>
    elm.review.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const paginatedReviews = filteredReviews.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handleMouseLeave = () => {
    setHoveredReview(null);
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
          {loading ? (<>
            <AdminPanelLoader />
          </>) : (<>
            <h1 className="text-30">Reviews</h1>
            <p className="">Explore and manage all reviews to ensure quality feedback and improve traveler experiences across destinations</p>

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
                    placeholder="Search reviews..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={{
                      paddingLeft: "40px",
                    }}
                  />
                </div>
              </div>

              <div className="overflowAuto">
                <table className="tableTest mb-30">
                  <thead className="bg-light-1 rounded-12">
                    <tr>
                      <th>ID</th>
                      <th>Username</th>
                      <th>Email</th>
                      <th>Review</th>
                    </tr>
                  </thead>

                  <tbody>
                    {paginatedReviews.length == 0 && <>
                      <tr>
                        <td colSpan="7" className="text-center h-50 ">
                          No reviews available.
                        </td>
                      </tr>
                    </>}
                    {paginatedReviews && paginatedReviews
                      .filter((elm) =>
                        elm.review.toLowerCase().includes(searchTerm.toLowerCase())
                      )
                      .map((elm, i) => (
                        <tr key={elm.review_id}>
                          <td>{(currentPage - 1) * itemsPerPage + i + 1}</td>
                          <td>{elm.first_name} {elm.last_name}</td>
                          <td>{elm.email}</td>
                          <td
                            className="min-w-300"
                            onMouseEnter={(e) => handleMouseEnter(e, elm.review)}
                            onMouseLeave={handleMouseLeave}
                            style={{
                              cursor: "pointer",
                              position: "relative",
                              borderRadius: "4px",
                              padding: "5px",
                            }}
                          >
                            {elm.review.length > 30
                              ? `${elm.review.substring(0, 110)}...`
                              : elm.review}
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>

                {hoveredReview && (
                  <div
                    className="popover"
                    style={{
                      top: `${popoverPosition.top}px`,
                      left: `${popoverPosition.left}px`,
                      position: "fixed",
                      backgroundColor: "#ffffff",
                      border: "1px solid #eb662b",
                      borderRadius: "8px",
                      padding: "15px",
                      textAlign: "justify",
                      boxShadow:
                        "0 8px 16px rgba(0, 0, 0, 0.2), 0 4px 6px rgba(0, 0, 0, 0.15)",
                      zIndex: 1000,
                      width: "300px",
                      maxHeight: "200px",
                      overflowY: "auto",
                      color: "#000000",
                    }}
                  >
                    {hoveredReview}
                  </div>
                )}
              </div>

              <Pagination
                totalItems={filteredReviews.length}
                itemsPerPage={itemsPerPage}
                currentPage={currentPage}
                onPageChange={handlePageChange}
              />

              <div className="text-14 text-center mt-20">
                Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredReviews.length)} of {reviews.length}
              </div>
            </div>
          </>)}
          <div className="text-center pt-30">
            © Copyright QuickRoute {new Date().getFullYear()}
          </div>
        </div>
      </div>
    </div>
  );
}
