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

// function errorCheck() {
//     if (document.getElementsByClassName("show").length === 0) {
//         errmsg = document.getElementById("no-spots-error");
//         removeClass(errmsg, "no-spots-error");
//         table = document.getElementById("spot-table");
//         addClass(table, "no-spots-error");
//     }
//     if (document.getElementsByClassName("show").length > 0) {
//         errmsg = document.getElementById("no-spots-error");
//         addClass(errmsg, "no-spots-error");
//         table = document.getElementById("spot-table");
//         removeClass(table, "no-spots-error");
//     }
// }
//
// function filterByType(spot_type) {
//     changeActiveButton("spot_type");
//     var otherFilter = document.getElementById("rating-filters").getElementsByClassName("active")[0].innerText;
//     var cards, i;
//     cards = document.getElementsByClassName("filterable");
//     if (spot_type === "all") spot_type = "";
//     // Add the "show" class to the filtered elements, and remove the "show" class from the elements that are not selected
//     for (i = 0; i < cards.length; i++) {
//         removeClass(cards[i], "show");
//         if (cards[i].className.indexOf(spot_type) > -1) addClass(cards[i], "show");
//     }
//     errorCheck()
// }
//
// function filterByRating(spot_rating) {
//     changeActiveButton("rating");
//     var cards, i;
//     cards = document.getElementsByClassName("filterable");
//     if (spot_rating === "all") spot_rating = "";
//     // Add the "show" class to the filtered elements, and remove the "show" class from the elements that are not selected
//     for (i = 0; i < cards.length; i++) {
//         removeClass(cards[i], "show");
//         for (s = spot_rating; s<=10; s++) {
//             if (cards[i].className.indexOf("rating-" + s) > -1) addClass(cards[i], "show");
//         }
//     }
//     errorCheck()
// }
//
// // Show filtered elements
// function addClass(element, name) {
//     var i, arr1, arr2;
//     arr1 = element.className.split(" ");
//     arr2 = name.split(" ");
//     for (i = 0; i < arr2.length; i++) {
//         if (arr1.indexOf(arr2[i]) === -1) {
//             element.className += " " + arr2[i];
//         }
//     }
// }
//
// // Hide elements that are not selected
// function removeClass(element, name) {
//     var i, arr1, arr2;
//     arr1 = element.className.split(" ");
//     arr2 = name.split(" ");
//     for (i = 0; i < arr2.length; i++) {
//         while (arr1.indexOf(arr2[i]) > -1) {
//             arr1.splice(arr1.indexOf(arr2[i]), 1);
//         }
//     }
//     element.className = arr1.join(" ");
// }
//
// function changeActiveButton(button_type) {
//     // Add active class to the current control button (highlight it)
//     // Remove active class from inactive buttons
//     var btnContainer, otherContainer;
//     if (button_type === "spot_type"){
//         btnContainer = document.getElementById("type-filters");
//         otherContainer = document.getElementById("rating-filters");
//     }else if (button_type === "rating"){
//         btnContainer = document.getElementById("rating-filters");
//         otherContainer = document.getElementById("type-filters");
//     }else {
//         console.log("button container type not known");
//     }
//
//     var btns = btnContainer.getElementsByClassName("btn");
//     var otherBtns = otherContainer.getElementsByClassName("btn");
//     for (var i = 0; i < btns.length; i++) {
//         btns[i].addEventListener("click", function () {
//             //set clicked button to active
//             var current = btnContainer.getElementsByClassName("active");
//             current[0].className = current[0].className.replace(" active", "");
//             this.className += " active";
//
//             //set active button from other row to inactive
//             var otherCurrent = otherContainer.getElementsByClassName("active");
//             otherCurrent[0].className = otherCurrent[0].className.replace(" active", "");
//             otherBtns[0].className += " active";
//         });
//     }
// }




