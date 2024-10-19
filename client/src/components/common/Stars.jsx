import React, { useEffect, useState } from "react";

export default function Stars({ star, font ,black, zero}) {
  const [rating, setRating] = useState([]);
  useEffect(() => {
    setRating([]);
    for (let i = Math.round(star); i >= 1; i--) {
      setRating((pre) => [...pre, "star"]);
    }
  }, []);
  return (
    <>
      {rating.map((elm, i) => (
        <div key={i}>
          <i
            className={`icon-star text-${font ? font : "10"} text-yellow-2`}
          ></i>
        </div>
      ))}
          <span className={black?"text-accent-1-dark":"text-white"}>{star}{zero && '.0'}</span>

    </>
  );
}
