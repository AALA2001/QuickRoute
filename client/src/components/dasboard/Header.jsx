import { Link } from "react-router-dom";

export default function Header({ setSideBarOpen }) {
  return (
    <div className="dashboard__content_header">
      <div className="d-flex items-center">
        <div className="mr-60">
          <button
            onClick={() => setSideBarOpen((pre) => !pre)}
            className="d-flex js-toggle-db-sidebar"
          >
            <i className="icon-main-menu text-20"></i>
          </button>
        </div>
      </div>

      <div>
        <Link  to="/admin/profile">
          <img src="../../../public/img/avatars/profile.png" alt="image" height={60} width={60}/>
        </Link>
      </div>
    </div>
  );
}
