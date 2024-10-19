import React from "react";
import Profile from "@/components/dasboard/DBProfile/Profile";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Manage Profile | QuickRoute",
  description: "View your admin profile details, including name and email. Update your password to ensure account security and maintain access to the travel management portal.",
};

export default function DBProfilePage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Profile />
      </main>
    </>
  );
}
