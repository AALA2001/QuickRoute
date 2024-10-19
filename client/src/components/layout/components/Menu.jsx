import { homes, pages, tours } from "@/data/menu";

import { Link, useLocation } from "react-router-dom";

import React from "react";

export default function Menu() {
  const { pathname } = useLocation();
  return (
    <>
      <div className="xl:d-none ml-30 ">
        <div className="desktopNav">
          <div className="desktopNav__item">
            <a href="/">Home</a>
          </div>

          <div className="desktopNav__item">
            <a href="/tour-list">Tour List</a>
          </div>

          <div className="desktopNav__item">
            <Link to="/reviews">Review</Link>
          </div>
        </div>
      </div>
    </>
  );
}
