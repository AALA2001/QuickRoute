import FooterOne from "@/components/layout/footers/FooterOne";
import Header1 from "@/components/layout/header/Header1";
import Activity from "@/components/pages/helpCenter/Activity";
import Faq from "@/components/pages/helpCenter/Faq";
import Hero from "@/components/pages/wishlist/Hero";
import React, { useEffect, useState } from "react";

import MetaComponent from "@/components/common/MetaComponent";
import WishlistCard from "./WishlistCard";
import Header3 from "@/components/layout/header/Header3";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import Loader from "@/components/Loader";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
    title: "Wishlist | QuickRoute",
    description: "Create and manage your personalized travel wishlist. Save your dream destinations and experiences, and easily plan for your future adventures with our intuitive app.",
};

export default function WishlistPage() {
    const navigate = useNavigate();
    const [wishlist, setWishlist] = useState([]);
    const [loading, setLoading] = useState(false);
    useEffect(() => {
        var token = localStorage.getItem("token");
        if (token == null) {
            toast.error("You need to log into your account first");
            navigate("/login")
        } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
            toast.error("Your session has expired, please log in again");
            navigate("/login")
        } else {
            setLoading(true)
            fetch(`http://localhost:9093/clientData/user/wishlist/${token}`)
                .then((data) => {
                    if (data.ok) {
                        return data.json();
                    } else {
                        toast.error("Failed to fetch wishlist");
                    }
                })
                .then((response) => {
                    setWishlist(response.wishlist);
                    setLoading(false)
                }).catch((error => console.log(error))).finally(() => {
                    setLoading(false)
                })
        }
    }, [])
    return (
        <>
            {loading ? (
                <Loader />
            ) : (
                <>
                    <MetaComponent meta={metadata} />
                    <main>
                        <Header3 />
                        <WishlistCard data={wishlist} />
                        <FooterThree />
                    </main>
                </>
            )}
        </>
    );
}
