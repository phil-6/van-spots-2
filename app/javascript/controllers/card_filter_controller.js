import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["spotTable", "noSpotsError", "filterable"];

    initialize() {
        this.filterByRating({ target: { dataset: { rating: 'all' } } });
        this.filterByType({ target: { dataset: { spotType: 'all' } } });
        console.log("Spot filter initialized");
    }

    errorCheck() {
        if (this.filterableTargets.filter(el => el.classList.contains("show")).length === 0) {
            this.noSpotsErrorTarget.classList.remove("no-spots-error");
            this.spotTableTarget.classList.add("no-spots-error");
        } else {
            this.noSpotsErrorTarget.classList.add("no-spots-error");
            this.spotTableTarget.classList.remove("no-spots-error");
        }
    }

    filterByType(event) {
        this.changeActiveButton("spot_type");
        const spotType = event.target.dataset.spotType || "";
        this.filterableTargets.forEach(card => {
            card.classList.remove("show");
            if (card.className.indexOf(spotType) > -1) {
                card.classList.add("show");
            }
        });
        this.errorCheck();
    }

    filterByRating(event) {
        this.changeActiveButton("rating");
        const rating = event.target.dataset.rating || "all";
        this.filterableTargets.forEach(card => {
            card.classList.remove("show");
            if (rating === "all" || parseInt(card.dataset.rating) >= parseInt(rating)) {
                card.classList.add("show");
            }
        });
        this.errorCheck();
    }

    changeActiveButton(buttonType) {
        const btnContainer = buttonType === "spot_type" ? this.element.querySelector("#type-filters") : this.element.querySelector("#rating-filters");
        const otherContainer = buttonType === "spot_type" ? this.element.querySelector("#rating-filters") : this.element.querySelector("#type-filters");

        const btns = btnContainer.getElementsByClassName("btn");
        const otherBtns = otherContainer.getElementsByClassName("btn");

        Array.from(btns).forEach(btn => {
            btn.addEventListener("click", function () {
                const current = btnContainer.getElementsByClassName("active")[0];
                current.classList.remove("active");
                this.classList.add("active");

                const otherCurrent = otherContainer.getElementsByClassName("active")[0];
                otherCurrent.classList.remove("active");
                otherBtns[0].classList.add("active");
            });
        });
    }
}
