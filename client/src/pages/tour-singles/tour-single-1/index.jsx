import FooterOne from "@/components/layout/footers/FooterOne";
import Header1 from "@/components/layout/header/Header1";
import PageHeader from "@/components/tourSingle/PageHeader";
import TourSlider from "@/components/tourSingle/TourSlider";
import SingleOne from "@/components/tourSingle/pages/SingleOne";
import { allTour } from "@/data/tours";
import { useParams } from "react-router-dom";
import React, { useEffect, useState } from "react";

import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import FooterThree from "@/components/layout/footers/FooterThree";
import Loader from "@/components/Loader";


export default function TourSinglePage1() {
  let params = useParams();
  const id = params.id;

  const [metaTitle, setMetaTitle] = useState(" ");
  const [metaDescription, setMetaDescription] = useState("");

  const [loading, setLoading] = useState(true);
  const [tourData, setTourData] = useState([]);
  const [related, setRelated] = useState([]);

  useEffect(() => {
    fetch(`http://localhost:9093/clientData/destinationLocation?destination_id=${id}`)
      .then((data) => data.json())
      .then((data) => {
        setLoading(false)
        setTourData(data.locations);
        const filteredRelatedLocations = data.relatedLocations.filter(
          (location) => location.location_id !== Number(id)
        );
        setRelated(filteredRelatedLocations);
        setMetaTitle(`${data.locations[0].title} | QuickRoute`);
        setMetaDescription(`${data.locations[0].overview}.`);
      })
      .catch((error) => console.error(error))
  }, [id])


  return (
    <>
      <MetaComponent meta={{"title": metaTitle, "description":metaDescription}}  />

      <main>
        {loading ? (<Loader />) : (
          <>
            <Header3 />
            <PageHeader />

            <SingleOne tour={tourData} id={id}/>
            <TourSlider related={related} locationId={id} />
            <FooterThree />
          </>
        )}

      </main>
    </>
  );
}
