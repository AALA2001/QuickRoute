import React from "react";
import Destinations from "@/components/dasboard/Destinations/DBDestinations";
import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Manage Destinations | QuickRoute",
  description: "View and manage destination details in the admin panel. Update locations, attractions, and travel information to enhance user experiences and keep content up-to-date.",
};

export default function DBDestinationsPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Destinations />
      </main>
    </>
  );
}
