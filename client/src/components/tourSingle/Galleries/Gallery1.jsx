import React from "react";

export default function Gallery1({tour}) {
  return (
    <>
      <div className="tourSingleGrid -type-1 mt-30">
        <div className="w-full">
          <img src={`http://localhost:9091/${tour?.image}`} alt="image" className="w-full h-auto" />
        </div>
      </div>
    </>
  );
}
