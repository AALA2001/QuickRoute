import DBListing from "@/components/dasboard/DBListing";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Dashboard-listing || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function DBListingPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <DBListing />
      </main>
    </>
  );
}
