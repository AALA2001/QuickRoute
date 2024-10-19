import { reviews } from "@/data/tourSingleContent";
import React, { useEffect, useState } from "react";
import Stars from "../common/Stars";
import Pagination from "../common/Pagination";

export default function Reviews({ tour }) {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 2;
  useEffect(() => {
    setLoading(true);
    fetch(`http://localhost:9093/clientData/locationReviews?location_id=${tour?.location_id}`)
      .then((data) => data.json())
      .then((data) => {
        setLoading(false)
        setReviews(data);
        console.log(data)
      })
      .catch((error) => {
        setLoading(false)
      })
      .finally(() => setLoading(false));
  }, [tour])
  const paginatedReviews = reviews?.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );
  const handlePageChange = (page) => {
    setCurrentPage(page);
  };
  return (
    <>
      {paginatedReviews.length == 0 && (<><p className=" pt-35">No reviews</p></>)}
      {paginatedReviews.length != 0 && paginatedReviews.map((elm, i) => (
        <div key={i} className="pt-30">
          <div className="row justify-between">
            <div className="col-auto">
              <div className="d-flex items-center">
                <div className="size-40 rounded-full">
                  <img src={'../../../public/img/avatars/profile.png'} alt="image" className="img-cover" />
                </div>

                <div className="text-16 fw-500 ml-20">{elm.first_name} {elm.last_name}</div>
              </div>
            </div>
          </div>

          <div className="d-flex items-center mt-15">
            <div className="d-flex x-gap-5">
              <Stars black={true} star={elm?.rating_count} zero={true} />
            </div>
            {/* <div className="text-16 fw-500 ml-10">{elm.reviewText}</div> */}
          </div>

          <p className="mt-10">{elm?.review}</p>

          <div className="row x-gap-20 y-gap-20 pt-20">

            <div className="col-auto">
              <div className="size-100">
                {elm?.review_img != null && (
                  <img
                    src={`http://localhost:9091/${elm?.review_img}`}
                    alt="image"
                    className="img-cover rounded-12"
                  />
                )}

              </div>
            </div>
          </div>
        </div>
      ))}
      <Pagination
        totalItems={reviews.length}
        itemsPerPage={itemsPerPage}
        currentPage={currentPage}
        onPageChange={handlePageChange}
      />
      <div className="text-14 text-center mt-20">
        Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, paginatedReviews.length)} of {reviews.length}
      </div>
    </>
  );
}
