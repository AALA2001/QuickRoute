import SpacialOffer from "@/components/homes/others/SpacialOffer";
import Hero from "@/components/pages/destinations/Hero";
import TourList1 from "@/components/pages/destinations/TourList";
import TourSlider from "@/components/pages/destinations/TourSlider";
import React, { useEffect, useState } from "react";

import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import { useNavigate, useParams } from "react-router-dom";
import Loader from "@/components/Loader";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
  title: "Destinations | QuickRoute ",
  description: "Find must-visit locations within your chosen destination. Explore popular attractions, hidden gems, and unique experiences to make the most of your travel adventure.",
};

export default function DestinationsPage() {
  const { id } = useParams()
  const [destination, setDestination] = useState({});
  const [offers, setOffers] = useState([]);
  const [locations, setLocations] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate()
  useEffect(() => {
    fetch(`http://localhost:9093/clientData/destination?destinationId=${id}`, {
      method: 'GET',
      headers: { 'Content-Type': "application/json" },
      credentials: 'include'
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          setLoading(false)
          setDestination(data.message.destination);
          setOffers(data.message.offers);
          setLocations(data.message.destinationLocations);
        } else {
          if (data.message == "Database error") {
            navigate('/not-found')
          }
        }
      })
      .catch(error => {
        console.error(error)
      });
  }, [])
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        {loading ? (<>
          <Loader />
        </>) : (<>
          <Header3 />
          <Hero destination={destination} />
          {offers.length != 0 && (<SpacialOffer data={offers} />)}
          {locations.length != 0 && (<TourSlider data={locations} destination={destination} />)}
          <TourList1 data={locations} destination={destination} />
          <FooterThree />
        </>)}
      </main>
    </>
  );
}
