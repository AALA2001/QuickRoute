import useToken from "@/hooks/useToken";
import { useEffect, useState } from "react";
import toast from "react-hot-toast";

export default function SelectWithSearchDestination({ selected, onSelect, reset }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedItem, setSelectedItem] = useState(selected);
  const [destinations, setDestinations] = useState([]);
  const [ddActive, setDdActive] = useState(false);
  const { token } = useToken();

  useEffect(() => {
    if (token) {
      fetch(`http://localhost:9092/data/admin/getDestinations/${token}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
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
            setDestinations(data.message);
          } else {
            toast.error(data.message);
          }
        })
        .catch((error) => {
          toast.error(error.message);
        });
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
        onClick={() => setDdActive((prev) => !prev)}
      >
        <span className="js-button-title">
          {selectedItem ? selectedItem : `Destination`}
        </span>
        <i className="select__icon" data-feather="chevron-down"></i>
      </button>

      <div
        className={`select__dropdown js-dropdown js-form-dd ${ddActive ? "-is-visible" : ""}`}
      >
        <input
          onChange={(e) => setSearchQuery(e.target.value)}
          type="text"
          placeholder="Search"
          className="select__search js-search h-full"
        />

        <div className="select__options js-options">
          {destinations
            ?.filter((elm) =>
              elm.title?.toLowerCase().includes(searchQuery?.toLowerCase())
            )
            .map((elm) => (
              <div
                onClick={() => {
                  setSelectedItem(elm.title);
                  setDdActive(false);
                  onSelect(elm.destination_id); 
                }}
                className="select__options__button"
                key={elm.destination_id}
              >
                {elm.title}
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}
