import { Link } from "react-router-dom";
import React, { useState } from "react";
import toast from "react-hot-toast";

export default function Register() {
  const [first_name, setFirstName] = useState('');
  const [last_name, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const newErrors = {};

  const validateForm = () => {
    if (!first_name.trim()) newErrors.firstName = "First name is required";
    if (!last_name.trim()) newErrors.lastName = "Last name is required";
    if (!email.trim()) newErrors.email = "Email is required";
    else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = "Email address is invalid";
    if (!password.trim()) newErrors.password = "Password is required";
    else if (password.length < 6) newErrors.password = "Password must be at least 6 characters";
    if (password !== confirmPassword) newErrors.confirmPassword = "Passwords do not match";
    return newErrors;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const validationErrors = validateForm();
    setErrors(validationErrors);

    if (Object.keys(validationErrors).length === 0) {
      const formData = { first_name, last_name, email, password };
      setLoading(true);
      fetch('http://localhost:9091/auth/user/register', {
        method: 'POST',
        credentials: 'include', 
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      })
        .then((response) => response.json())
        .then((data) => {
          setLoading(false)
          if(data.success){
            toast.success(data.content)
            localStorage.setItem("token",data.token)
            setFirstName("");
            setLastName("");
            setEmail("");
            setPassword("");
            setConfirmPassword("");
          }
        })
        .catch((error) => {
          setLoading(false)
          console.error('Error:', error)
        });
    }
  };

  return (
    <section
      className="layout-pt-lg layout-pb-lg"
      style={{ backgroundImage: "url('img/hero/3/bg.jpg')", backgroundSize: "cover", backgroundPosition: "center" }}
    >
      <div className="container bg-white shadow-1 p-4 mt-40" style={{ borderRadius: 20 }}>
        <div className="row justify-between">
          <div className="col-xl-6 col-lg-7 col-md-9">
            <img
              src="img/register/register-bg.png"
              className="w-100 h-full img-cover"
              style={{ borderTopLeftRadius: 20, borderBottomLeftRadius: 20 }}
            />
          </div>
          <div className="col-xl-6 col-lg-7 col-md-9">
            <div className="text-center mb-60 md:mb-30 mt-40">
              <h1 className="text-30">Register</h1>
              <div className="text-18 fw-500 mt-20 md:mt-15">Let's create your account!</div>
              <div className="mt-5">
                Already have an account?{" "}
                <Link to="/login" className="text-accent-1">
                  Log In!
                </Link>
              </div>
            </div>
            <form onSubmit={handleSubmit} className="contactForm rounded-12 px-60 pb-10 md:px-25 md:py-30">
              <div className="form-input mt-30">
                <input
                  type="text"
                  value={first_name}
                  onChange={(e) => setFirstName(e.target.value)}
                  className={`${first_name ? 'not-empty' : ''}`}
                />
                <label className="lh-1 text-16 text-light-1">First Name</label>
              </div>
              {errors.firstName && <p className="text-red-1 ms-2 mt-5">{errors.firstName}</p>}
              <div className="form-input mt-30">
                <input
                  type="text"
                  value={last_name}
                  onChange={(e) => setLastName(e.target.value)}
                  className={`${last_name ? 'not-empty' : ''}`}
                />
                <label className="lh-1 text-16 text-light-1">Last Name</label>
              </div>
              {errors.lastName && <p className="text-red-1 ms-2 mt-5">{errors.lastName}</p>}
              <div className="form-input mt-30">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className={`${email ? 'not-empty' : ''}`}
                />
                <label className="lh-1 text-16 text-light-1">Your Email</label>
              </div>
              {errors.email && <p className="text-red-1 ms-2 mt-5">{errors.email}</p>}
              <div className="form-input mt-30">
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className={`${password  ? 'not-empty' : 'border-red'}`}
                />
                <label className="lh-1 text-16 text-light-1">Password</label>
              </div>
              {errors.password && <p className="text-red-1 ms-2 mt-5">{errors.password}</p>}
              <div className="form-input mt-30">
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className={`${confirmPassword ? 'not-empty' : ''}`}
                />
                <label className="lh-1 text-16 text-light-1">Confirm Password</label>
              </div>
              {errors.confirmPassword && <p className="text-red-1">{errors.confirmPassword}</p>}
              <button className="button -md -dark-1 bg-accent-1 text-white col-12 mt-30">
                Register
                <i className="icon-arrow-top-right ml-10"></i>
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}