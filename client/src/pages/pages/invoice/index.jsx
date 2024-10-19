import Invoice from "@/components/Invoice";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Invoice || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function InvoicePage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Invoice />
      </main>
    </>
  );
}
