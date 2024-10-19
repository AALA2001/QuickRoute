import React, { useEffect, useState } from 'react';
import Popover from '@mui/material/Popover';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import toast from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import decodeJWT from '@/util/JWTDecode';
import getCurrentTimeISO from '@/util/CurrentTimeIOS';

const AddToPlanPopover = ({ anchorEl, handleClose,destinations_id }) => {
    const [selectedItem, setSelectedItem] = useState([]);
    const navigate = useNavigate();
    const [planItem, setPlanItem] = useState([]);
    const [newPlan, setNewPlan] = useState("");
    const [planId, setPlanId] = useState();
    const [newPlanPopoverAnchor, setNewPlanPopoverAnchor] = useState(null);
    const handleCheckboxChange = (id) => {
        setPlanId(id);
        if (selectedItem === id) {
            setSelectedItem(null);
        } else {
            setSelectedItem(id);
        }
    };
    const handleOpenNewPlanPopover = (event) => {
        setNewPlanPopoverAnchor(event.currentTarget);
    };
    const handleCloseNewPlanPopover = () => {
        setNewPlanPopoverAnchor(null);
    };
    const [loading, setLoading] = useState(false);
    const handleAddNewPlan = () => {
        var token = localStorage.getItem("token");
        if (token == null) {
            toast.error("You need to log into your account first");
            navigate("/login")
        } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
            toast.error("Your session has expired, please log in again");
            navigate("/login")
        } else {
            fetch(`http://localhost:9093/clientData/plan/create/${token}?planName=${newPlan}`)
                .then((data) => data.json())
                .then((response) => {
                    if (response.success) {
                        toast.success("Plan created successfully");
                        setPlanItem([...planItem, { plan_id: response.planId, plan_name: response.planName }]);
                        setNewPlan("");
                        handleCloseNewPlanPopover();
                    } else {
                        toast.error(response.message);
                    }
                    setLoading(false)
                }).catch((error => console.log(error))).finally(() => {
                    setLoading(false)
                })
        }
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
                        setPlanItem([])
                    } else {
                        toast.error("Failed to fetch trip plans");
                    }
                })
                .then((response) => {
                    setPlanItem(response.plans);
                    setLoading(false)
                }).catch((error => console.log(error))).finally(() => {
                    setLoading(false)
                })
        }
    }, [])
    return (
        <div>
            <Popover
                open={Boolean(anchorEl)}
                anchorEl={anchorEl}
                onClose={handleClose}
                anchorOrigin={{
                    vertical: 'center',
                    horizontal: 'right',
                }}
                transformOrigin={{
                    vertical: 'center',
                    horizontal: 'left',
                }}
                PaperProps={{
                    style: {
                        borderRadius: '15px',
                        padding: '20px',
                    },
                }}
            >
                <div style={{ width: '100%' }}>
                    <h5 className='mb-3 me-2'>Select Plan to Add</h5>
                    <div className="col-md-4 h-200 overflow-scroll-y" style={{ width: '100%' }}>
                        {planItem.map((item, index) => (
                            <div className="d-flex items-center mb-10" key={index}>
                                <div className="form-checkbox">
                                    <input
                                        type="checkbox"
                                        name="plan"
                                        checked={selectedItem === item.plan_id}
                                        onChange={() => handleCheckboxChange(item.plan_id)}
                                    />
                                    <div className="form-checkbox__mark">
                                        <div className="form-checkbox__icon">
                                            <svg
                                                width="10"
                                                height="8"
                                                viewBox="0 0 10 8"
                                                fill="none"
                                                xmlns="http://www.w3.org/2000/svg"
                                            >
                                                <path
                                                    d="M9.29082 0.971021C9.01235 0.692189 8.56018 0.692365 8.28134 0.971021L3.73802 5.51452L1.71871 3.49523C1.43988 3.21639 0.987896 3.21639 0.709063 3.49523C0.430231 3.77406 0.430231 4.22604 0.709063 4.50487L3.23309 7.0289C3.37242 7.16823 3.55512 7.23807 3.73783 7.23807C3.92054 7.23807 4.10341 7.16841 4.24274 7.0289L9.29082 1.98065C9.56965 1.70201 9.56965 1.24984 9.29082 0.971021Z"
                                                    fill="white"
                                                />
                                            </svg>
                                        </div>
                                    </div>
                                </div>
                                <div className="text-14 lh-12 ml-10 col-auto">{item.plan_name}</div>
                            </div>
                        ))}
                    </div>
                    <button
                        className="button -outline-accent-1 text-accent-1 px-15 py-10 mt-25 col-12"
                        onClick={handleOpenNewPlanPopover}
                    >
                        Add New Plan
                    </button>
                    <button
                        className="button bg-accent-1 text-white px-15 py-10 mt-10 col-12"
                        onClick={() => {
                            var token = localStorage.getItem("token");
                            if (token == null) {
                                toast.error("You need to log into your account first");
                                navigate("/login")
                            } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
                                toast.error("Your session has expired, please log in again");
                                navigate("/login")
                            } else {
                                setLoading(true)
                                fetch(`http://localhost:9093/clientData/plan/userPlan/addDestination/${token}?plan_id=${planId}&destination_id=${destinations_id}`)
                                    .then((data) => {
                                        if (data.ok) {
                                            return data.json();
                                        } else if (data.status == 404) {
                                            setPlanItem([])
                                        } else if(data.status == 409) {
                                            toast.error("You have already added this destination to this plan")
                                        }else{
                                            toast.error("Failed to add destination to plan")
                                        }
                                    })
                                    .then((response) => {
                                        if (response.success) {
                                            toast.success("Destination added to plan successfully");
                                            setLoading(false)
                                        }
                                    }).catch((error => console.log(error))).finally(() => {
                                        setLoading(false)
                                    })
                            }
                        }}
                    >
                        Add to Plan
                        <i className="icon-arrow-top-right ml-10"></i>
                    </button>
                </div>
            </Popover>
            <Popover
                open={Boolean(newPlanPopoverAnchor)}
                anchorEl={newPlanPopoverAnchor}
                onClose={handleCloseNewPlanPopover}
                anchorOrigin={{
                    vertical: 'center',
                    horizontal: 'right',
                }}
                transformOrigin={{
                    vertical: 'center',
                    horizontal: 'left',
                }}
                PaperProps={{
                    style: {
                        padding: '20px',
                        borderRadius: '15px',
                    },
                }}
            >
                <div style={{ width: '250px' }}>
                    <h5 className='mb-3'>Add New Plan</h5>
                    <TextField
                        fullWidth
                        label="New Plan"
                        variant="outlined"
                        value={newPlan}
                        onChange={(e) => setNewPlan(e.target.value)}
                    />
                    <button
                        onClick={handleAddNewPlan}
                        className='button -outline-accent-1 text-accent-1 px-15 py-10 mt-25 col-12'
                    >
                        Add
                    </button>
                </div>
            </Popover>
        </div>
    );
};

export default AddToPlanPopover;