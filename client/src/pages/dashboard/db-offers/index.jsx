import React from "react";
import Offers from "@/components/dasboard/DBOffers/DBOffers";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Manage Offers | QuickRoute",
  description: "Administer travel offers and special deals in the admin panel. Add, edit, or remove discounts to keep the latest promotions up-to-date for users.",
};

export default function DBOffersPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Offers />
      </main>
    </>
  );
}
