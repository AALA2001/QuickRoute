import Login from "@/components/pages/Login";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
  title: "Login | QuickRoute ",
  description: "Log in to your travel planner account to access personalized itineraries, manage your wishlist, and plan your next adventure effortlessly.",
};

export default function LoginPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Header3 />
        <Login />
        <FooterThree />
      </main>
    </>
  );
}
