import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./styles/style.css";
import Aos from "aos";
import { useEffect } from "react";
import HomePage3 from "./pages/homes/home-3";
import ScrollTopBehaviour from "./components/common/ScrollTopBehavier";
import ScrollToTop from "./components/common/ScrollToTop";
import TourListPage6 from "./pages/tour-lists/tour-list-6";
import TourSinglePage1 from "./pages/tour-singles/tour-single-1";
import DestinationsPage from "./pages/pages/destinations";
import HelpCenterPage from "./pages/pages/help-center";
import LoginPage from "./pages/pages/login";
import RegisterPage from "./pages/pages/register";
import NotFoundPage from "./pages/pages/404";
import ContactPage from "./pages/pages/contact";
import WishlistPage from "./pages/pages/wishlist";
import PlansPage from "./pages/your-plans";
import Suggestions from "./pages/suggetions";
import ReviewsPage from "./pages/reviews";
import Invoice from "./components/Invoice";

import DBMainPage from "./pages/dashboard/db-main";
import DBDestinationsPage from "./pages/dashboard/db-destinations";
import AddDestination from "./components/dasboard/Destinations/AddDestination";
import DBLocationsPage from "./pages/dashboard/db-locations";
import AddLocation from "./components/dasboard/DBLocations/AddLocation";
import DBOffersPage from "./pages/dashboard/db-offers";
import AddOffer from "./components/dasboard/DBOffers/AddOffer";
import DBReviewsPage from "./pages/dashboard/db-reviews";
import LocationReviews from "./components/dasboard/DBLocations/LocationReviews";
import DBProfilePage from "./pages/dashboard/db-profile";
import AdminLoginPage from "./pages/pages/adminLogin";

function App() {
  useEffect(() => {
    Aos.init({
      duration: 800,
      once: true,
    });
  }, []);

  return (
    <>
      <BrowserRouter>
        <Routes>
          <Route path="/">
            <Route index element={<HomePage3 />} />
            <Route path="/home" element={<HomePage3 />} />
            <Route path="/tour-list" element={<TourListPage6 />} />
            <Route path="/tour-single/:id" element={<TourSinglePage1 />} />

            <Route path="/destinations/:id" element={<DestinationsPage />} />
            <Route path="/help-center" element={<HelpCenterPage />} />
            <Route path="/wishlist" element={<WishlistPage />} />
            <Route path="/your-plans" element={<PlansPage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route path="/contact" element={<ContactPage />} />
            <Route path="/admin-login" element={<AdminLoginPage />} />
            <Route path="/suggestions/:id" element={<Suggestions />} />
            <Route path="/reviews" element={<ReviewsPage />} />
            <Route path="/itinerary-download" element={<Invoice />} />

            {/* Dashboard */}
            <Route path="/admin/dashboard" element={<DBMainPage />} />
            <Route path="/admin/destinations" element={<DBDestinationsPage />} />
            <Route path="/admin/destinations/add-destination" element={<AddDestination />} />
            <Route path="/admin/destinations/edit-destination" element={<AddDestination />} />
            <Route path="/admin/locations" element={<DBLocationsPage />} />
            <Route path="/admin/locations/add-location" element={<AddLocation />} />
            <Route path="/admin/locations/edit-location" element={<AddLocation />} />
            <Route path="/admin/locations/location-reviews" element={<LocationReviews />} />
            <Route path="/admin/offers" element={<DBOffersPage />} />
            <Route path="/admin/offers/add-offer" element={<AddOffer />} />
            <Route path="/admin/offers/edit-offer" element={<AddOffer />} />
            <Route path="/admin/reviews" element={<DBReviewsPage />} />
            <Route path="/admin/profile" element={<DBProfilePage />} />

            <Route path="/404" element={<NotFoundPage />} />
            <Route path="/*" element={<NotFoundPage />} />
          </Route>
        </Routes>
        <ScrollTopBehaviour />
      </BrowserRouter>
      <ScrollToTop />
    </>
  );
}

export default App;
