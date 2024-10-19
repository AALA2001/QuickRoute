import { sidebarItems } from "@/data/dashboard";
import { Link, useLocation, useNavigate } from "react-router-dom";

import React from "react";

export default function Sidebar({ setSideBarOpen }) {
  const { pathname } = useLocation();
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("token");
    setSideBarOpen(false);
  };
  return (
    <div className="dashboard__sidebar js-dashboard-sidebar">
      <div className="dashboard__sidebar_header">
        <span
          onClick={() => setSideBarOpen(false)}
          class="text-white closeSidebar"
        >
          &times;
        </span>
        <Link to={"/"}>
          <img src="../../../public/img/logo/3.png" alt="logo" width={200} height={200}/>
        </Link>
      </div>

      <div className="sidebar -dashboard">
        {sidebarItems.map((elm, i) => (
          <div
            key={i}
            className={`sidebar__item ${pathname == elm.href ? "-is-active" : ""
              } `}
          >
            <Link to={elm.href}>
              <i className={elm.iconClass}></i>
              <span className="ml-10">{elm.label}</span>
            </Link>
          </div>
        ))}
        <div className=" sidebar__item">
          <Link to={'/'} onClick={handleLogout}>
            <i className={'icon-logout text-26'}></i>
            <span className="ml-10">Logout</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
