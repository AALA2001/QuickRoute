import React from "react";

export default function Overview({ tour }) {
  return (
    <>
      <h2 className="text-30">Tour Overview</h2>
      <p className="mt-20">
        {tour?.overview}
      </p>
    </>
  );
}
