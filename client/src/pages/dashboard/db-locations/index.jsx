import DbBooking from "@/components/dasboard/DbBooking";
import React from "react";
import Locations from "@/components/dasboard/DBLocations/DBLocations";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Manage Locations | QuickRoute",
  description: "Administer and update location details within destinations. Add, edit locations to ensure accurate travel information and enhance user experience.",
};

export default function DBLocationsPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Locations />
      </main>
    </>
  );
}
