import useToken from "@/hooks/useToken";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import decodeJWT from "@/util/JWTDecode";
import React, { useEffect, useState } from "react";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";

export default function AdminLogin() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [errors, setErrors] = useState({});
    const navigate = useNavigate();
    const newErrors = {};

    const { token } = useToken()

    useEffect(() => {
        if (token !== null) {
            if (token == null) {
                toast.error("You need to log into your account first");
                navigate("/admin-login")
            } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
                toast.error("Your session has expired, please log in again");
                navigate("/admin-login")
            } else if (decodeJWT(token).userType == "admin" && decodeJWT(token).expiryTime >= getCurrentTimeISO()) {
                navigate('/admin/dashboard')
            }
        }
    }, [token]);

    const validateForm = () => {
        if (!email.trim()) newErrors.email = "Email is required";
        else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = "Email address is invalid";
        if (!password.trim()) newErrors.password = "Password is required";
        return newErrors;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        const validationErrors = validateForm();
        setErrors(validationErrors);
        if (Object.keys(validationErrors).length === 0) {
            const formData = { email, password };
            fetch('http://localhost:9091/auth/admin/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
                credentials: 'include',
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        localStorage.setItem('token', data.token)
                        navigate('/admin/dashboard')
                        toast.success(data.content)
                        setEmail("");
                        setPassword("");
                    } else {
                        toast.error(data.content)
                    }
                })
                .catch(error => console.error("Error" + error));
        }
    }
    return (
        <section className="layout-pt-lg layout-pb-lg"
            style={{
                backgroundImage: "url('img/hero/3/bg.jpg')",
                backgroundSize: "cover",
                backgroundPosition: "center",
            }}
        >
            <div className="container bg-white  shadow-1 p-4 mt-40" style={{ borderRadius: 20 }}>
                <div className="row justify-between">
                    <div className="col-xl-6 col-lg-7 col-md-9 d-flex row justify-center align-items-center">
                        <div className="text-center md:mb-30 mt-50">
                            <h1 className="text-30">Admin Log In</h1>
                            <div className="text-18 fw-500 mt-20 md:mt-15">
                                We're glad to see you again!
                            </div>
                        </div>
                        <form
                            onSubmit={(e) => e.preventDefault()}
                            className="contactForm rounded-12 px-60 pb-10 md:px-25 md:py-30"
                        >
                            <div className="form-input mt-30 contactForm">
                                <input
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className={email ? 'not-empty' : ''}
                                />
                                <label className="lh-1 text-16 text-light-1">Your Email</label>
                            </div>
                            {errors.email && <p className="text-red-1 ms-2 mt-5">{errors.email}</p>}
                            <div className="form-input mt-30">
                                <input
                                    type="password"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className={`${password ? 'not-empty' : 'border-red'}`}
                                />
                                <label className="lh-1 text-16 text-light-1">Password</label>
                            </div>
                            {errors.password && <p className="text-red-1 ms-2 mt-5">{errors.password}</p>}
                            <button onClick={handleSubmit} className="button -md -dark-1 bg-accent-1 text-white col-12 mt-30">
                                Login
                                <i className="icon-arrow-top-right ml-10"></i>
                            </button>
                        </form>
                    </div>
                    <div className="col-xl-6 col-lg-7 col-md-9 ">
                        <img src="img/login/admin-login-bg.jpg" className="w-100 h-full img-cover" style={{ borderTopRightRadius: 20, borderBottomRightRadius: 20 }} />
                    </div>
                </div>
            </div>
        </section>
    );
}
