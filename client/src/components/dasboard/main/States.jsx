import { states } from "@/data/dashboard";
import useToken from "@/hooks/useToken";
import React, { useEffect, useState } from "react";
import toast from "react-hot-toast";

export default function States({count}) {

  return (
    <div className="row y-gap-30 pt-60 md:pt-30">

      <div className="col-xl-3 col-sm-6">
        <div className="rounded-12 bg-white shadow-2 px-30 py-30 h-full">
          <div className="row y-gap-20 items-center justify-between">
            <div className="col-auto">
              <div>Total Destinations</div>
              <div className="text-30 fw-700">{count.destinations}</div>
            </div>
            <div className="col-auto">
              <div className="size-80 flex-center bg-accent-1-05 rounded-full">
                <i className={`text-30 text-accent-1 icon-calendar`}></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="col-xl-3 col-sm-6">
        <div className="rounded-12 bg-white shadow-2 px-30 py-30 h-full">
          <div className="row y-gap-20 items-center justify-between">
            <div className="col-auto">
              <div>Total Locations</div>
              <div className="text-30 fw-700">{count.locations}</div>
            </div>
            <div className="col-auto">
              <div className="size-80 flex-center bg-accent-1-05 rounded-full">
                <i className={`text-30 text-accent-1 icon-pin`}></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="col-xl-3 col-sm-6">
        <div className="rounded-12 bg-white shadow-2 px-30 py-30 h-full">
          <div className="row y-gap-20 items-center justify-between">
            <div className="col-auto">
              <div>Total Offers</div>
              <div className="text-30 fw-700">{count.offers}</div>
            </div>
            <div className="col-auto">
              <div className="size-80 flex-center bg-accent-1-05 rounded-full">
                <i className={`text-30 text-accent-1 icon-clipboard`}></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="col-xl-3 col-sm-6">
        <div className="rounded-12 bg-white shadow-2 px-30 py-30 h-full">
          <div className="row y-gap-20 items-center justify-between">
            <div className="col-auto">
              <div>Total Reviews</div>
              <div className="text-30 fw-700">{count.reviews}</div>
            </div>
            <div className="col-auto">
              <div className="size-80 flex-center bg-accent-1-05 rounded-full">
                <i className={`text-30 text-accent-1 icon-review`}></i>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  );
}
