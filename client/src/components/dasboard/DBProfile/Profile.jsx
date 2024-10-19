import Sidebar from "../Sidebar";
import Header from "../Header";
import { useEffect, useState } from "react";
import toast from "react-hot-toast";
import decodeJWT from "@/util/JWTDecode";
import getCurrentTimeISO from "@/util/CurrentTimeIOS";
import useToken from "@/hooks/useToken";

export default function Profile() {
  const [sideBarOpen, setSideBarOpen] = useState(true);
  const [oldPw, setOldPw] = useState("");
  const [newPw, setNewPw] = useState("");
  const [payload, setPayload] = useState("");
  const [confirmPw, setConfirmPw] = useState("");
  const { token } = useToken()

  useEffect(() => {
    if (token !== null) {
      if (token == null) {
        toast.error("You need to log into your account first");
        navigate("/admin-login")
      } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
        toast.error("Your session has expired, please log in again");
        navigate("/admin-login")
      } else {
        const decoded = decodeJWT(token);
        setPayload(decoded)
      }
    }
  }, [token]);

  const handleSubmit = () => {
    if (oldPw === "") {
      toast.error("Old password required");
    } else if (newPw === "") {
      toast.error("New password required");
    } else if (!newPw.match("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$")) {
      toast.error('Password must be at least 8 characters long and contain atleast one uppercase letter, one lowercase letter, one digit, and one special character')
    } else if (confirmPw === "") {
      toast.error("Confirm password required");
    } else if (newPw !== confirmPw) {
      toast.error("Passwords do not match");
    } else {
      fetch(`http://localhost:9092/data/admin/updatePassword/${token}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          old_password: oldPw,
          new_password: newPw,
          email: payload.email,
        }),
        credentials: "include",
      })
        .then((response) => {
          if (response.status === 401) {
            navigate('/admin-login');
            toast.error("Session Expired.");
          }
          return response.json();
        })
        .then((data) => {
          if (data.success) {
            toast.success("Password updated successfully");
            setNewPw("")
            setOldPw("")
            setConfirmPw("")
          } else {
            toast.error(data?.message);
          }
        })
        .catch((error) => {
          toast.error("An error occurred: " + error.message);
        });
    }
  };

  return (
    <>
      <div className={`dashboard ${sideBarOpen ? "-is-sidebar-visible" : ""} js-dashboard`}>
        <Sidebar setSideBarOpen={setSideBarOpen} />

        <div className="dashboard__content">
          <Header setSideBarOpen={setSideBarOpen} />

          <div className="dashboard__content_content">
            <h1 className="text-30">My Profile</h1>
            <p className="">View and manage your profile information</p>
            <div className="mt-50 rounded-12 bg-white shadow-2 px-40 pt-40 pb-30">
              <div className="profile-card d-flex align-center justify-between">
                <div className="profile-details">
                  <h2 className="text-20 font-bold mb-5">
                    {payload?.first_name} {payload?.last_name}
                  </h2>
                  <p className="text-16 text-light-1">{payload?.email}</p>
                </div>
                <div className="profile-avatar">
                  <img
                    src="../../../../public/img/avatars/profile.png"
                    alt="User Avatar"
                    className="rounded-circle"
                    style={{
                      width: "80px",
                      height: "80px",
                      objectFit: "cover",
                    }}
                  />
                </div>
              </div>
            </div>

            <div className="rounded-12 bg-white shadow-2 px-40 pt-40 pb-30 mt-30">
              <h5 className="text-20 fw-500 mb-30">Change Password</h5>

              <div className="contactForm y-gap-30">
                <div className="row y-gap-30">
                  <div className="col-md-6">
                    <div className="form-input">
                      <input
                        type="password"
                        required
                        value={oldPw}
                        onChange={(e) => setOldPw(e.target.value)}
                        className={oldPw ? "not-empty" : ""}
                      />
                      <label className="lh-1 text-16 text-light-1">Old password</label>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-6">
                    <div className="form-input">
                      <input
                        type="password"
                        required
                        value={newPw}
                        onChange={(e) => setNewPw(e.target.value)}
                        className={newPw ? "not-empty" : ""}
                      />
                      <label className="lh-1 text-16 text-light-1">New password</label>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-6">
                    <div className="form-input">
                      <input
                        type="password"
                        required
                        value={confirmPw}
                        onChange={(e) => setConfirmPw(e.target.value)}
                        className={confirmPw ? "not-empty" : ""}
                      />
                      <label className="lh-1 text-16 text-light-1">Confirm new password</label>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-12">
                    <button onClick={handleSubmit} className="button -md -dark-1 bg-accent-1 text-white">
                      Save Changes
                      <i className="icon-arrow-top-right text-16 ml-10"></i>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div className="text-center pt-30">© Copyright QuickRoute {new Date().getFullYear()}</div>
          </div>
        </div>
      </div>
    </>
  );
}
