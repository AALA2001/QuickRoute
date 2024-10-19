import React, { useEffect, useState } from "react";
import Stars from "@/components/common/Stars";
import Pagination from "@/components/common/Pagination";
import AddToPlanPopover from "@/components/common/AddToPlanPopover";
import toast from "react-hot-toast";
import { Link } from "react-router-dom";
import EmptyWishlist from "@/components/common/EmptyWishlist";

export default function WishlistCard({ data }) {
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedTour, setSelectedTour] = useState(null);
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const [destination_location_id, setDestination_location_id] = useState();
    const itemsPerPage = 5;

    const filteredWishlist = data?.filter((elm) =>
        elm.destination_location_title.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const paginatedWishlist = filteredWishlist.slice(
        (currentPage - 1) * itemsPerPage,
        currentPage * itemsPerPage
    );

    const handlePageChange = (page) => {
        setCurrentPage(page);
    };

    const handleOpenPopover = (event, elm) => {
        setAnchorEl(event.currentTarget);
        setSelectedTour(elm);
        setDestination_location_id(elm.destinations_id)
    };

    const handleClosePopover = () => {
        setAnchorEl(null);
        setSelectedTour(null);
    };

    return (
        <>
            <section className="pageHeader -type-2">
                <div className="pageHeader__bg">
                    <img src="/img/pageHeader/2.jpg" alt="image" />
                    <img src="/img/hero/1/shape.svg" alt="image" />
                </div>

                <div className="container">
                    <div className="row justify-center">
                        <div className="col-12">
                            <div className="pageHeader__content">
                                <h1 className="pageHeader__title">Wishlist</h1>
                                <p className="pageHeader__text">
                                    Create and manage your personalized travel wishlist
                                </p>
                                <div className="pageHeader__search">
                                    <input type="text" placeholder="Search for a topic"
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value)}
                                    />
                                    <button>
                                        <i className="icon-search text-15 text-white"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            <section className="layout-pb-xl">
                <div className="container">
                    <div className="row">
                        <div className="col-xl-12 col-lg-12">
                            {paginatedWishlist.length > 0 ? (
                                <>
                                    <div className="row y-gap-30 pt-30">
                                        {paginatedWishlist.map((elm, i) => (
                                            <div className="col-12" key={i}>
                                                <div className="tourCard -type-2">
                                                    <div className="tourCard__image">
                                                        <Link to={`/tour-single/${elm.destinations_id}`}>
                                                            <img src={`http://localhost:9091/${elm.image}`} alt="image" />
                                                        </Link>
                                                        <div className="tourCard__favorite">
                                                            <button onClick={() => {
                                                                const token = localStorage.getItem('token');
                                                                fetch(`http://localhost:9093/clientData/user/wishlist/removeDestination/${token}`, {
                                                                    method: 'DELETE',
                                                                    headers: {
                                                                        'Content-Type': 'application/json',
                                                                    },
                                                                    credentials: 'include',
                                                                    body: JSON.stringify({ destinations_id: elm.destinations_id })
                                                                })
                                                                    .then((response) => {
                                                                        if (response.status == 401) {
                                                                            toast.error("Unauthorized. Please login to continue.")
                                                                        }
                                                                        return response.json();
                                                                    })
                                                                    .then((data) => {
                                                                        if (data.success) {
                                                                            toast.success("Successfully removed from wishlist")
                                                                            window.location.reload()
                                                                        }
                                                                    })
                                                                    .catch((error) => {
                                                                        console.error('Error:', error);
                                                                        toast.error(error.message)
                                                                    })
                                                            }} className="button -accent-1 size-35 bg-white rounded-full flex-center">
                                                                <i className="icon-delete text-15"></i>
                                                            </button>
                                                        </div>
                                                    </div>
                                                    <div className="tourCard__content">
                                                        <div className="tourCard__location">
                                                            <i className="icon-pin"></i>
                                                            {elm.destination_title}, {elm.country_name}
                                                        </div>
                                                        <Link to={`/tour-single/${elm.destinations_id}`}>
                                                            <h3 className="tourCard__title mt-5">
                                                                <span>{elm.destination_location_title}</span>
                                                            </h3>
                                                        </Link>
                                                        <div className="d-flex items-center mt-5">
                                                            <div className="d-flex items-center x-gap-5">
                                                                {elm.average_rating == null ? (
                                                                    <span>No reviews</span>
                                                                ) : (
                                                                    <Stars star={elm.average_rating} font={12} black={true} />
                                                                )}
                                                            </div>
                                                            <div className="text-14 ml-10">
                                                                <span className="fw-500">{elm.rating}</span> ({elm.total_ratings})
                                                            </div>
                                                        </div>
                                                        <p className="tourCard__text tourCard__text--clamp mt-5">{elm.overview}</p>
                                                    </div>
                                                    <div className="tourCard__info d-flex justify-center">
                                                        <button
                                                            className="button -outline-accent-1 text-accent-1 p-10 h-50 d-flex justify-center align-items-center"
                                                            onClick={(e) => handleOpenPopover(e, elm)}
                                                        >
                                                            <span><i className="icon-arrow-top-right ml-10"></i> Add to Plan</span>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                    <div className="d-flex justify-center flex-column mt-60">
                                        <Pagination
                                            totalItems={filteredWishlist.length}
                                            itemsPerPage={itemsPerPage}
                                            currentPage={currentPage}
                                            onPageChange={handlePageChange}
                                        />
                                        <div className="text-14 text-center mt-20">
                                            Showing results {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredWishlist.length)} of {filteredWishlist.length}
                                        </div>
                                    </div>
                                </>
                            ) : (
                                <EmptyWishlist />
                            )}
                        </div>
                    </div>
                </div>
                {selectedTour && (
                    <AddToPlanPopover
                        anchorEl={anchorEl}
                        handleClose={handleClosePopover}
                        destinations_id={destination_location_id}
                    />
                )}
            </section>
        </>
    );
}