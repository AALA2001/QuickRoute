import React, { useState, useEffect, useMemo } from "react";
import { Link } from "react-router-dom";
import Pagination from "@/components/common/Pagination";
import CreatePlan from "@/components/models/CreatePlan";
import EmptyPlans from "@/components/common/EmptyPlans";

export default function PlanCard({ data, searchText }) {
    const [open, setOpen] = useState(false);
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 6;
    const images = ["/img/trip-plan/trip-plan-1.png", "/img/trip-plan/trip-plan-2.png", "/img/trip-plan/trip-plan-3.png"];
    const filteredPlans = useMemo(() => {
        return data?.filter((elm) =>
            elm.plan_name.toLowerCase().includes(searchText.toLowerCase())
        );
    }, [data, searchText]);
    const paginatedPlans = useMemo(() => {
        return filteredPlans.slice(
            (currentPage - 1) * itemsPerPage,
            currentPage * itemsPerPage
        );
    }, [filteredPlans, currentPage, itemsPerPage]);
    const handlePageChange = (page) => {
        setCurrentPage(page);
    };
    const getRandomImages = (numImages) => {
        let shuffledImages = [...images];
        let result = [];
        let prevImage = null;
        for (let i = 0; i < numImages; i++) {
            let availableImages = shuffledImages.filter(img => img !== prevImage);
            let randomImage = availableImages[Math.floor(Math.random() * availableImages.length)];
            result.push(randomImage);
            prevImage = randomImage;
        }
        return result;
    };
    const [randomImages, setRandomImages] = useState([]);
    useEffect(() => {
        setRandomImages(getRandomImages(paginatedPlans.length));
    }, [paginatedPlans]);
    return (
        <section className="layout-pb-xl">
            <div className="container">
                <CreatePlan open={open} setOpen={setOpen} />
                <div className="row">
                    <div className="d-flex justify-end">
                        <Link
                            onClick={() => setOpen(true)}
                            to=""
                            className="button -sm -dark-1 bg-accent-1 rounded-200 text-white"
                        >
                            <i className="icon-plus me-2"></i>
                            Create a Plan
                        </Link>
                    </div>
                    <div className="col-xl-12 col-lg-12">
                        {paginatedPlans.length > 0 ? (
                            <>
                                <div className="row y-gap-30 pt-30">
                                    {paginatedPlans.map((elm, i) => (
                                        <div key={i} className="col-md-4">
                                            <Link
                                                to={`/suggestions/${elm.plan_id}`}
                                                className="tourCard -type-3 -hover-image-scale"
                                            >
                                                <div className="tourCard__image ratio ratio-41:45 rounded-12 -hover-image-scale__image">
                                                    <img
                                                        src={randomImages[i]}
                                                        alt="image"
                                                        className="img-ratio rounded-12"
                                                    />
                                                </div>
                                                <div className="tourCard__wrap">
                                                    <div className="tourCard__header d-flex justify-between items-center text-13 text-white">
                                                    </div>
                                                    <div className="tourCard__content">
                                                        <div>
                                                            <h3 className="tourCard__title text-18 text-white fw-500 mt-5">
                                                                <h2 className="text-white capitalize">{elm.plan_name}</h2>
                                                            </h3>
                                                        </div>
                                                    </div>
                                                </div>
                                            </Link>
                                        </div>
                                    ))}
                                </div>
                                <div className="d-flex justify-center flex-column mt-60">
                                    <Pagination
                                        totalItems={filteredPlans.length}
                                        itemsPerPage={itemsPerPage}
                                        currentPage={currentPage}
                                        onPageChange={handlePageChange}
                                    />
                                    <div className="text-14 text-center mt-20">
                                        Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredPlans.length)} of {filteredPlans.length}
                                    </div>
                                </div>
                            </>
                        ) : (
                            <EmptyPlans />
                        )}
                    </div>
                </div>
            </div>
        </section>
    );
}