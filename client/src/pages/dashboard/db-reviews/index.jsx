import React from "react";
import DBReviews from "@/components/dasboard/DBReviews/DBReviews";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Manage Reviews | QuickRoute",
  description: "Access and manage user reviews in the admin panel. Approve, edit, or delete feedback to maintain quality content and enhance the travel planning experience.",
};

export default function DBReviewsPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <DBReviews />
      </main>
    </>
  );
}
