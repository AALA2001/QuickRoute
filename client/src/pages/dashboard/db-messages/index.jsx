import Messages from "@/components/dasboard/Messages";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Dashboard-messages || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function DBMessagesPage() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Messages />
      </main>
    </>
  );
}
