import React, { useEffect, useState } from "react";
import SuggetionsHero from "@/components/tours/SuggetionsHero"
import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import SingleThree from "@/components/tourSingle/pages/SingleThree";
import { useNavigate, useParams } from "react-router-dom";
import { allTour } from "@/data/tours";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import toast from "react-hot-toast";
import FooterThree from "@/components/layout/footers/FooterThree";
import Loader from "@/components/Loader";

const metadata = {
    title: "PlansPage || ViaTour - Travel & Tour Reactjs Template",
    description: "ViaTour - Travel & Tour Reactjs Template",
};

export default function Suggestions() {
    let params = useParams();
    const id = params.id;
    const [itinerary, setItinerary] = useState([]);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

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
            fetch(`http://localhost:9093/clientData/generateItinerary/${token}?trip_plan_id=${id}`, {
                method: 'POST',
            })
                .then((data) => {
                    return data.json();
                })
                .then((response) => {
                    if(response.success){
                        setItinerary(response.itineraries);
                    }else{
                        toast.error(response.message);
                        navigate('/your-plans')
                    }
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
                {loading ? (<><Loader /></>) : (<>
                    <Header3 />
                    <SuggetionsHero />
                    <SingleThree data={itinerary} />
                    <FooterThree />
                </>)}

            </main>
        </>
    );
}
