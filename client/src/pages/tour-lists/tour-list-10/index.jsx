import FooterOne from "@/components/layout/footers/FooterOne";
import Header1 from "@/components/layout/header/Header1";
import Style1 from "@/components/tours/ListStyle.jsx/Style1";
import Style2 from "@/components/tours/ListStyle.jsx/Style2";
import Style3 from "@/components/tours/ListStyle.jsx/Style3";
import Style4 from "@/components/tours/ListStyle.jsx/Style4";
import Style5 from "@/components/tours/ListStyle.jsx/Style5";
import Style6 from "@/components/tours/ListStyle.jsx/Style6";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Tour-list-10 || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function TourListPage10() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <div style={{ borderBottom: "1px solid #E7E6E6" }}>
          <Header1 />
        </div>
        <Style1 />
        <Style2 />
        <Style3 />
        <Style4 />
        <Style5 />
        <Style6 />
        <FooterOne />
      </main>
    </>
  );
}
