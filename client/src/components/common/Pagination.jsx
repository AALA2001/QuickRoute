import React, { useState, useEffect } from "react";

export default function Pagination({
  totalItems,
  itemsPerPage = 5,
  currentPage = 1,
  onPageChange,
}) {
  const [activePage, setActivePage] = useState(currentPage);
  const totalPages = Math.ceil(totalItems / itemsPerPage);

  useEffect(() => {
    setActivePage(currentPage);
  }, [currentPage]);

  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= totalPages) {
      setActivePage(newPage);
      onPageChange(newPage);
    }
  };

  return (
    <div className="pagination justify-center">
      <button
        onClick={() => handlePageChange(activePage - 1)}
        disabled={activePage === 1}
        className="pagination__button customStylePaginationPre button -accent-1 mr-15 -prev"
      >
        <i className="icon-arrow-left text-15"></i>
      </button>

      <div className="pagination__count">
        {Array.from({ length: totalPages }, (_, index) => index + 1).map((page) => (
          <div
            key={page}
            style={{ cursor: "pointer" }}
            onClick={() => handlePageChange(page)}
            className={activePage === page ? "is-active" : ""}
          >
            {page}
          </div>
        ))}
      </div>

      <button
        onClick={() => handlePageChange(activePage + 1)}
        disabled={activePage === totalPages}
        className="pagination__button customStylePaginationNext button -accent-1 ml-15 -next"
      >
        <i className="icon-arrow-right text-15"></i>
      </button>
    </div>
  );
}
