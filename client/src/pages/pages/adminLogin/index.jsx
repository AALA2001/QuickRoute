import React from "react";

import MetaComponent from "@/components/common/MetaComponent";
import Header3 from "@/components/layout/header/Header3";
import AdminLogin from "@/components/pages/AdminLogin";
import FooterThree from "@/components/layout/footers/FooterThree";

const metadata = {
    title: "Admin Login | QuickRoute",
    description: "Log in to the admin portal to manage travel content, review user activity, and oversee itinerary planning. Access your admin dashboard securely.",
};

export default function AdminLoginPage() {
    return (
        <>
            <MetaComponent meta={metadata} />
            <main>
                <Header3 />
                <AdminLogin />
                <FooterThree />
            </main>
        </>
    );
}
