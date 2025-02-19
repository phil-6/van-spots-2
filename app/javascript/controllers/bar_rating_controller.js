import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["select", "widget", "currentRating"];

    connect() {
        this.buildWidget();
        this.applyStyle();
        this.showSelectedRating();
        this.setupHandlers();
        this.selectTarget.style.display = "none";
    }

    buildWidget() {
        const widget = document.createElement("div");
        widget.classList.add("br-widget", "br-theme-bars-pill"); // Add the theme class

        this.selectTarget.querySelectorAll("option").forEach(option => {
            const a = document.createElement("a");
            a.href = "#";
            a.dataset.ratingValue = option.value;
            a.dataset.ratingText = option.text;
            a.innerHTML = this.data.get("showValues") === "true" ? option.text : "";
            widget.appendChild(a);
        });

        if (this.data.get("showSelectedRating") === "true") {
            const currentRating = document.createElement("div");
            currentRating.classList.add("br-current-rating");
            widget.appendChild(currentRating);
        }

        this.selectTarget.insertAdjacentElement('afterend', widget); // Insert widget after select element
        this._widgetTarget = widget; // Use a private property
    }

    applyStyle() {
        const selectedValue = this.selectTarget.value;
        const initialRating = this.data.get("initialRating");
        const baseValue = isNaN(selectedValue) ? 0 : selectedValue;
        const f = this.fraction(initialRating);

        this.resetStyle();

        // Find the anchor element with the selected rating value
        const a = this._widgetTarget.querySelector(`a[data-rating-value="${selectedValue}"]`);
        if (a) {
            a.classList.add('br-selected', 'br-current');
            let sibling = a;
            while (sibling = sibling.previousElementSibling) {
                sibling.classList.add('br-selected');
            }
        }

        if (!this.data.get("ratingMade") && !isNaN(initialRating)) {
            if (initialRating <= baseValue || !f) {
                return;
            }

            const allAnchors = this._widgetTarget.querySelectorAll('a');
            let fractional = a ? (this.data.get("reverse") ? a.nextElementSibling : a.previousElementSibling) : (this.data.get("reverse") ? allAnchors[allAnchors.length - 1] : allAnchors[0]);

            if (fractional) {
                fractional.classList.add('br-fractional', `br-fractional-${f}`);
            }
        }
    }

    resetStyle() {
        this._widgetTarget.querySelectorAll('a').forEach(a => {
            a.className = a.className.replace(/\bbr-\S+/g, '');
        });
    }

    fraction(value) {
        return Math.round(((Math.floor(value * 10) / 10) % 1) * 100);
    }

    showSelectedRating() {
        const selectedOption = this.selectTarget.selectedOptions[0];
        const text = selectedOption ? selectedOption.text : "";
        if (this.data.get("showSelectedRating") === "true") {
            this._widgetTarget.querySelector(".br-current-rating").textContent = text;
        }
    }

    setupHandlers() {
        this._widgetTarget.querySelectorAll("a").forEach(a => {
            a.addEventListener("click", this.handleClick.bind(this));
            a.addEventListener("mouseenter", this.handleMouseEnter.bind(this));
        });
        this._widgetTarget.addEventListener("mouseleave", this.handleMouseLeave.bind(this));
    }

    handleClick(event) {
        event.preventDefault();
        const a = event.currentTarget;
        this.selectTarget.value = a.dataset.ratingValue;
        this.applyStyle();
        this.showSelectedRating();
        this.selectTarget.dispatchEvent(new Event("change"));
    }

    handleMouseEnter(event) {
        const a = event.currentTarget;
        this._widgetTarget.querySelectorAll("a").forEach(a => a.classList.remove("br-active"));
        a.classList.add("br-active");
    }

    handleMouseLeave() {
        this._widgetTarget.querySelectorAll("a").forEach(a => a.classList.remove("br-active"));
        this.applyStyle();
    }
}
