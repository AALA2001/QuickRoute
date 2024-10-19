import Register from "@/components/pages/Register";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
  title: "Register | QuickRote",
  description: "Sign up to start planning your perfect trips. Create an account to access personalized itineraries, save your favorite destinations, and explore new travel experiences.",
};

export default function RegisterPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Header3 />
        <Register />
        <FooterThree />
      </main>
    </>
  );
}
