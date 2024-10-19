import React from "react";
import ReviewsHero from "@/components/tours/ReviewsHero"
import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import { useParams } from "react-router-dom";
import { allTour } from "@/data/tours";
import ReviewsComment from "@/components/tourSingle/pages/ReviewsComment";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
    title: "Reviews | QuickRoute",
    description: "Share your travel experiences and insights! Write a review of your recent adventures to help others discover amazing destinations and make informed travel choices.",
};

export default function ReviewsPage() {
    let params = useParams();
    const id = params.id;
    const tour = allTour.find((item) => item.id == id) || allTour[0];
    return (
        <>
            <MetaComponent meta={metadata} />
            <main>
                <Header3 />
                <ReviewsHero />
                <ReviewsComment tour={tour} />
                <FooterThree />
            </main>
        </>
    );
}
