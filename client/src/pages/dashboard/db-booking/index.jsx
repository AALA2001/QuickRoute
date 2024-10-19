import DbBooking from "@/components/dasboard/DbBooking";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Dashboard-booking || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function DBBookingPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <DbBooking />
      </main>
    </>
  );
}
