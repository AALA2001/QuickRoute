import React, { useEffect, useState } from "react";
import Menu from "../components/Menu";
import Currency from "../components/Currency";
import MobileMenu from "../components/MobileMenu";

import { Link, useNavigate } from "react-router-dom";

export default function Header3() {
  const navigate = useNavigate();

  const pageNavigate = (pageName) => {
    navigate(pageName);
  };

  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [addClass, setAddClass] = useState(false);

  const handleScroll = () => {
    if (window.scrollY >= 50) {
      setAddClass(true);
    } else {
      setAddClass(false);
    }
  };

  useEffect(() => {
    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);
  return (
    <>
      <header
        className={`header -type-3 js-header ${addClass ? "-is-sticky" : ""}`}
      >
        <div className="header__container container">
          <div className="headerMobile__left">
            <button
              onClick={() => setMobileMenuOpen(true)}
              className="header__menuBtn js-menu-button"
            >
              <i className="icon-main-menu"></i>
            </button>
          </div>

          <div className="header__logo">
            <Link to="/" className="header__logo">
              <img src="/img/logo/2.png" className="" alt="logo icon" height={230} width={180}/>
            </Link>

            <Menu />

          </div>
          <div className="headerMobile__right">
            <Link
              to=""
              className="button text-13 -sm -dark-1  bg-accent-1 rounded-200 text-white"
            >
              <i className="icon-plus me-2"></i>
              Create a Plan
            </Link>
          </div>

          <div className="header__right">

            <div className="desktopNav__item">
              <Link to="/wishlist">
                <i className="text-20 icon-heart"></i>
              </Link>
            </div>

            <Link
              to="/your-plans"
              className="button -sm -dark-1 ms-4 bg-accent-1 rounded-200 text-white"
            >
              <i className="icon-plus me-2"></i>
              Create a Plan
            </Link>
          </div>
        </div>
      </header>
      <MobileMenu
        setMobileMenuOpen={setMobileMenuOpen}
        mobileMenuOpen={mobileMenuOpen}
      />
    </>
  );
}
