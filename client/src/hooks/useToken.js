import { useEffect, useState } from "react";

const useToken = () => {
    const [token, setToken] = useState(null);

    useEffect(() => {
        const storedToken = localStorage.getItem('token');
        setToken(storedToken);
    }, []);

    return { token };
};

export default useToken;