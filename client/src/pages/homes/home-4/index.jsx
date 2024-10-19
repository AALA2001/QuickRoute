import ArticlesOne from "@/components/homes/articles/ArticlesOne";
import BannerSeven from "@/components/homes/banners/BannerSeven";
import PopulerDestinations from "@/components/homes/destinations/PopulerDestinations";
import TrendingDestinationsTwo from "@/components/homes/destinations/TrendingDestinationsTwo";
import FeaturesOne from "@/components/homes/features/FeaturesOne";
import Hero4 from "@/components/homes/heros/Hero4";
import TestimonialsThree from "@/components/homes/testimonials/TestimonialsThree";
import FeaturedToures from "@/components/homes/tours/FeaturedToures";
import FooterFour from "@/components/layout/footers/FooterFour";

import Header3 from "@/components/layout/header/Header3";
import React from "react";

import MetaComponent from "@/components/common/MetaComponent";

const metadata = {
  title: "Home-4 || ViaTour - Travel & Tour Reactjs Template",
  description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function HomePage4() {
  return (
    <>
      <MetaComponent meta={metadata} />
      <main>
        <Header3 />
        <Hero4 />
        <PopulerDestinations />
        <FeaturesOne />
        <div className="mt-50">
          <FeaturedToures />
        </div>
        <TrendingDestinationsTwo />
        <TestimonialsThree />
        <ArticlesOne />
        <BannerSeven />
        <FooterFour />
      </main>
    </>
  );
}
