import useToken from "@/hooks/useToken";
import { useEffect, useState } from "react";
import toast from "react-hot-toast";

export default function SelectWithSearchCountry({  selected, onSelect, reset }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedItem, setSelectedItem] = useState(selected);
  const [countries, setCountries] = useState([]);
  const [ddActive, setDdActive] = useState(false);
  const { token } = useToken()

  useEffect(() => {
    if (token) {
      fetch(`http://localhost:9092/data/admin/getCountries/${token}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include'
      })
        .then((response) => {
          if (response.status == 401) {
            navigate('/admin-login');
            toast.error("Session Expired.");
          }
          return response.json();
        })
        .then((data) => {
          if (data.success) {
            setCountries(data.message)
          } else {
            toast.error(data.message);
          }
        })
        .catch((error) => {
          toast.error(error.message);
        })
    }
  }, [token]);

  useEffect(() => {
    if (reset) {
      setSelectedItem(null);
      setSearchQuery("");
    }
  }, [reset]);

  return (
    <div className="select js-select js-liveSearch" data-select-value="">
      <button
        className="select__button js-button"
        onClick={() => setDdActive((pre) => !pre)}
      >
        <span className="js-button-title">
          {selectedItem ? selectedItem : `Country`}
        </span>
        <i className="select__icon" data-feather="chevron-down"></i>
      </button>

      <div
        className={`select__dropdown js-dropdown js-form-dd ${ddActive ? "-is-visible" : ""
          }`}
      >
        <input
          onChange={(e) => setSearchQuery(e.target.value)}
          type="text"
          placeholder="Search"
          className="select__search js-search"
        />

        <div className="select__options js-options">
          {countries
            ?.filter((elm) =>
              elm.name?.toLowerCase().includes(searchQuery?.toLowerCase()),
            )
            .map((elm) => (
              <div
                onClick={() => {
                  setSelectedItem(elm.name);
                  setDdActive(false);
                  onSelect(elm.id)
                }}
                className="select__options__button"
                key={elm.id}
              >
                {elm.name}
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}
