import Header3 from "@/components/layout/header/Header3";
import Hero from "@/components/tours/Hero";
import TourList5 from "@/components/tours/TourList5";
import React, { useEffect, useState } from "react";
import MetaComponent from "@/components/common/MetaComponent";
import Loader from "@/components/Loader";
import { useLocation } from "react-router-dom";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
  title: "Tour-list | QuickRoute - Travel & Tour Reactjs Template",
  description: "Discover a variety of tours and curated travel itineraries. Find your ideal journey, from popular destinations to unique experiences, and start planning your next adventure.",
};

export default function TourListPage6() {
  const { state } = useLocation();
  const [locations, setLocations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filteredLocations, setFilteredLocations] = useState([]);

  useEffect(() => {
    fetch("http://localhost:9093/clientData/destinationLocations")
      .then((data) => data.json())
      .then((response) => {
        setLocations(response);
        setLoading(false);
      })
      .catch((error) => console.log(error));
  }, []);

  useEffect(() => {
    if (!loading && state && (state.country || state.destination || state.tourType)) {
      filterLocations(state.country, state.destination, state.tourType);
    } else {
      setFilteredLocations(locations);
    }
  }, [locations, state, loading]);

  const filterLocations = (selectedCountry, selectedDestination, selectedTourType) => {
    const filtered = locations.filter((location) => {
      const matchesCountry = selectedCountry ? location?.country_name === selectedCountry : true;
      const matchesDestination = selectedDestination ? location?.destination_title === selectedDestination : true;
      const matchesTourType = selectedTourType ? location?.tour_type === selectedTourType : true;
      return matchesCountry && matchesDestination && matchesTourType;
    });

    setFilteredLocations(filtered);
  };

  return (
    <>
      {loading ? (
        <Loader />
      ) : (
        <>
          <main>
            <Header3 />
            <Hero onSearch={filterLocations} />
            <TourList5 data={filteredLocations} />
            <FooterThree />
          </main>
        </>
      )}
      <MetaComponent meta={metadata} />
    </>
  );
}
