import FooterOne from "@/components/layout/footers/FooterOne";
import Header1 from "@/components/layout/header/Header1";
import Activity from "@/components/pages/helpCenter/Activity";
import Faq from "@/components/pages/helpCenter/Faq";
import Hero from "@/components/pages/your-plans/Hero";
import React, { useEffect, useState } from "react";

import MetaComponent from "@/components/common/MetaComponent";
import PlanCard from "../../components/pages/your-plans/PlanCard";
import Header3 from "@/components/layout/header/Header3";
import { useNavigate } from "react-router-dom";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import toast from "react-hot-toast";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
    title: "PlansPage || ViaTour - Travel & Tour Reactjs Template",
    description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function PlansPage() {
    const navigate = useNavigate();
    const [plans, setPlans] = useState([]);
    const [loading, setLoading] = useState(false);
    const [searchText, setSearchText] = useState("");

    const handleSearchTextChange = (text) => {
        setSearchText(text);
    };

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
            fetch(`http://localhost:9093/clientData/plan/allPlans/${token}`)
                .then((data) => {
                    if (data.ok) {
                        return data.json();
                    } else if (data.status == 404) {
                        setPlans([])
                    } else {
                        toast.error("Failed to fetch wishlist");
                    }
                })
                .then((response) => {
                    setPlans(response.plans);
                    setLoading(false)
                }).catch((error => console.log(error))).finally(() => {
                    setLoading(false)
                })
        }
    }, [])
    return (
        <>
            <MetaComponent meta={metadata} />
            <main>
                <Header3 />
                <Hero onSearchTextChange={handleSearchTextChange}/>
                <PlanCard data={plans} searchText={searchText}/>
                <FooterThree />
            </main>
        </>
    );
}
