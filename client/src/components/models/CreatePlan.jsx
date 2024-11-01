import * as React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Modal from '@mui/material/Modal';
import { useState } from 'react';
import SelectWithSearch from '../pages/uiElements/SelectWithSearch';
import decodeJWT from '@/util/JWTDecode';
import getCurrentTimeISO from '@/util/CurrentTimeIOS';
import toast from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';

const style = {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: '30%',
    bgcolor: 'background.paper',
    borderRadius: 3,
    outline: 'none',
    boxShadow: 24,
    p: 4,
    '@media (max-width: 600px)': {
        width: '95%',
    },
};

function CreatePlan({ open, setOpen }) {
    const [name, setName] = useState('');
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();
    const handleClose = () => setOpen(false);

    return (
        <div>
            <Modal
                open={open}
                onClose={handleClose}
                aria-labelledby="modal-modal-title"
                aria-describedby="modal-modal-description"
            >
                <Box sx={style}>
                    <div className="col-12 d-flex align-items-center mb-4">
                        <div className="col-11">
                            <h3>Name for Your Plan</h3>
                        </div>
                        <div className="col-1">
                            <Button onClick={handleClose}>
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    width="24"
                                    height="24"
                                    fill="none"
                                    stroke="#000000"
                                    strokeWidth="2"
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                >
                                    <line x1="18" y1="6" x2="6" y2="18" />
                                    <line x1="6" y1="6" x2="18" y2="18" />
                                </svg>
                            </Button>
                        </div>
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            Plan Name
                        </label>
                        <div className="form-input contactForm">
                            <input required 
                            type="text"
                            className="form-control"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            />
                        </div>
                    </div>
                    <div className="col-12 mt-10 d-flex justify-content-end">
                        <div className="col-auto">
                            <button
                                className="button -md -accent-1 bg-accent-1-dark text-white"
                                onClick={() => {
                                    var token = localStorage.getItem("token");
                                    if (token == null) {
                                        toast.error("You need to log into your account first");
                                        navigate("/login")
                                    } else if (decodeJWT(token).expiryTime <= getCurrentTimeISO()) {
                                        toast.error("Your session has expired, please log in again");
                                        navigate("/login")
                                    } else {
                                    fetch(`http://localhost:9093/clientData/plan/create/${token}?planName=${name}`)
                                        .then((data) => data.json())
                                        .then((response) => {
                                            console.log(response)
                                            if (response.success) {
                                                toast.success("Plan created successfully");
                                                window.location.reload()
                                            }else{
                                                toast.error(response.message);
                                            }
                                            setLoading(false)
                                        }).catch((error => console.log(error))).finally(() => {
                                            setLoading(false)
                                        })
                                    }
                                    handleClose();
                                }}
                            >
                                <i className="icon-arrow-top-right text-16 mr-10"></i>
                                <span className="text-16 lh-1 fw-500">Create Plan</span>
                            </button>
                        </div>
                    </div>
                </Box>
            </Modal>
        </div>
    );
}

export default CreatePlan;
