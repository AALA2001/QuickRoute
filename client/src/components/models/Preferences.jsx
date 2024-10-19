import * as React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Modal from '@mui/material/Modal';
import SelectWithSearch from '../pages/uiElements/SelectWithSearch';
import { useState, useEffect } from 'react';
import RangeSlider from '../common/RangeSlider';

const style = {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: "30%",
    bgcolor: 'background.paper',
    borderRadius: 3,
    outline: "none",
    boxShadow: 24,
    p: 4,
    '@media (max-width: 600px)': {
        width: "95%",
    }
};

function Preferences() {
    const [open, setOpen] = React.useState(true);
    const handleClose = () => setOpen(false);
    const [destinationCountry, setDestinationCountry] = useState([]);
    const [currency, setCurrency] = useState([]);
    const [tourType, setTourType] = useState([]);
    const [weather, setWeather] = useState([]);

    useEffect(() => {
        setDestinationCountry([
            { id: 1, value: "USA", label: "USA" },
            { id: 2, value: "Canada", label: "Canada" },
            { id: 3, value: "Mexico", label: "Mexico" },
        ]);
        setCurrency([
            { id: 1, value: "USD", label: "USD" },
            { id: 2, value: "CAD", label: "CAD" },
            { id: 3, value: "MXN", label: "MXN" },
        ]);
        setTourType([
            { id: 1, value: "Adventure", label: "Adventure" },
            { id: 2, value: "Culture", label: "Culture" },
            { id: 3, value: "Food", label: "Food" },
        ]);
        setWeather([
            { id: 1, value: "Sunny", label: "Sunny" },
            { id: 2, value: "Rainy", label: "Rainy" },
            { id: 3, value: "Cloudy", label: "Cloudy" },
        ]);
    }, []);

    return (
        <div>
            <Modal
                open={open}
                onClose={handleClose}
                aria-labelledby="modal-modal-title"
                aria-describedby="modal-modal-description"
            >
                <Box sx={style}>
                    <div className='col-12 d-flex align-items-center mb-4'>
                        <div className='col-11'>
                            <h3>Select Your Preferences</h3>
                        </div>
                        <div className='col-1'>
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
                            Select Destination Country
                        </label>
                        <SelectWithSearch options={destinationCountry} />
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            Select Currency
                        </label>
                        <SelectWithSearch options={currency} />
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            Expected Trip Planned Day
                        </label>
                        <div className="form-input contactForm">
                            <input type="number" required />
                        </div>
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            What Type of Weather Do You Like?
                        </label>
                        <SelectWithSearch options={weather} />
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            What Kind of Trip Do You Like?
                        </label>
                        <SelectWithSearch options={tourType} />
                    </div>
                    <div className='col-12 mb-3'>
                        <label className="text-16 lh-1 fw-500 text-dark-1 mb-10">
                            Budget Range for Trip
                        </label>
                        <div className="js-price-rangeSlider">
                            <div className="px-5">
                                <RangeSlider />
                            </div>
                        </div>
                    </div>
                    <div className='col-12 mt-10 d-flex justify-content-end'>
                        <div className="col-auto">
                            <button className="button -md -accent-1 bg-accent-1-dark text-white">
                                <i className="icon-arrow-top-right text-16 mr-10"></i>
                                <span className="text-16 lh-1 fw-500">Save my Choices</span>
                            </button>
                        </div>
                    </div>
                </Box>
            </Modal>
        </div>
    );
}

export default Preferences;