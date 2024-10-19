import SpacialOffer from "@/components/homes/others/SpacialOffer";
import Hero3 from "@/components/homes/heros/Hero3";
import TourSlider5 from "@/components/homes/tours/TourSlider5";
import FooterThree from "@/components/layout/footers/FooterThree";
import Header3 from "@/components/layout/header/Header3";
import PopulerDestinations from "@/components/homes/destinations/PopulerDestinations";
import BannerFour from "@/components/homes/banners/BannerFour";
import TestimonialsFive from "@/components/homes/testimonials/TestimonialsFive";
import React, { useEffect, useState } from "react";
import FeturesTwo from "@/components/homes/features/FeturesTwo";
import BannerEight from "@/components/homes/banners/BannerEight";
import MetaComponent from "@/components/common/MetaComponent";
import TrendingDestinations3 from "@/components/homes/destinations/TrendingDestinations3";
import Loader from "@/components/Loader";

const metadata = {
  title: "Home | QuickRoute",
  description: "Create personalized day-by-day itineraries, discover must-see attractions, and explore hidden gems effortlessly. Start your journey today!",
};

export default function HomePage3() {
  const [destinationLocation, setDestinationLocation] = useState([]);
  const [userSiteReviews, setUserSiteReviews] = useState([]);
  const [destinations_with_location_count, setDestinations_with_location_count] = useState([]);
  const [offers, setOffers] = useState([]);
  const [bannerData, setBannerData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("http://localhost:9093/clientData/homepage")
      .then((data) => data.json())
      .then((data) => {
        setDestinationLocation(data?.destinationLocation);
        setUserSiteReviews(data?.userSiteReviews);
        setDestinations_with_location_count(data?.destinations_with_location_count);
        setOffers(data?.offers);
        setBannerData(data?.bannerData);
        setLoading(false);
      })
      .catch((error) => console.error(error))
  }, [])
  return (
    <>
      {loading ? (<Loader />) :
        (<>
          <MetaComponent meta={metadata} />
          <main>
            <Header3 />
            <Hero3 />
            {offers?.length != 0 && (<SpacialOffer data={offers} />)}
            {destinationLocation?.length != 0 && (<TourSlider5 data={destinationLocation} />)}
            <BannerEight />
            <TrendingDestinations3 data={destinations_with_location_count} />
            <PopulerDestinations />
            <BannerFour />
            <FeturesTwo data={bannerData} />
            <TestimonialsFive data={userSiteReviews} />
            <FooterThree />
          </main>
        </>)
      }
    </>
  );
}
