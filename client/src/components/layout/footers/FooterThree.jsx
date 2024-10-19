import Paymentcards from "../components/Paymentcards";
import FooterLinks from "../components/FooterLinks";
import Socials from "../components/Socials";

export default function FooterThree() {
  return (
    <footer className="footer -type-1">
      <div className="container">
        <div className="footer__bottom">
          <div className="row y-gap-5 justify-center items-center">
            <div className="col-auto">
              <div>© Copyright QuickRoute {new Date().getFullYear()}</div>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}