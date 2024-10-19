import DBMain from "@/components/dasboard/main";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Dashboard | QuickRoute",
  description: "Access the admin dashboard to manage destinations, locations, user reviews, and site content. Streamline operations and keep the travel planner running smoothly.",
};

export default function DBMainPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <DBMain />
      </main>
    </>
  );
}
