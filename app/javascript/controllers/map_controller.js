// app/javascript/controllers/map_controller.js
import {Controller} from "@hotwired/stimulus";
import {MarkerClusterer} from "@googlemaps/markerclusterer";

export default class extends Controller {
    static targets = ["map"];

    connect() {
        this.map = null;
        this.markers = [];
        this.markerCluster = null;
        this.userPos = null;
        this.infoWindow = null;
        this.newMarker = null;
        this.newMarkerInfoWindow = null;
        this.icons = JSON.parse(this.mapTarget.dataset.mapIcons);
        this.singleSpot = (typeof this.mapTarget.dataset.mapSpot != "undefined");
        if (this.singleSpot) this.spot = JSON.parse(this.mapTarget.dataset.mapSpot);

        this.initMap();
    }

    async initMap() {
        const {Map} = await google.maps.importLibrary("maps");
        let center = this.singleSpot ? {lat: parseFloat(this.spot.latitude), lng: parseFloat(this.spot.longitude)} : {
            lat: 51.6,
            lng: -4.15
        };
        let zoom = this.singleSpot ? 15 : 12;
        this.map = new Map(this.mapTarget, {
            center: center,
            zoom: zoom,
            mapTypeControl: true,
            mapTypeControlOptions: {
                position: google.maps.ControlPosition.LEFT_BOTTOM,
            },
            streetViewControl: false,
            fullscreenControl: false,
            scaleControl: true,
            mapTypeId: "terrain",
            mapId: "a2b97596989ec0c3"
        });

        if (!(this.map instanceof google.maps.Map)) {
            console.error("Map initialization failed.");
            return;
        }

        this.infoWindow = new google.maps.InfoWindow();
        this.newMarkerInfoWindow = new google.maps.InfoWindow({map: this.map});

        fetch("/api/spots")
            .then((response) => response.json())
            .then((data) => {
                data.forEach((item) => {
                    // console.log(item);
                    const position = new google.maps.LatLng(item.latitude, item.longitude);
                    const marker = new google.maps.Marker({
                        map: this.map,
                        position: position,
                        id: item.id,
                        name: item.name,
                        description: item.description,
                        average_rating: item.average_rating,
                        type: item.spot_type,
                        icon: this.icons[item.spot_type],
                        animation: google.maps.Animation.DROP,
                    });

                    this.markers.push(marker);
                    marker.addListener("click", () => {
                        this.populateInfoWindow(marker, this.infoWindow);
                    });
                });
                this.initMarkerCluster();
            });

        const mapFilterControlsDiv = document.createElement("div");
        this.MapFilterControls(mapFilterControlsDiv, this.map);
        mapFilterControlsDiv.index = 1;
        this.map.controls[google.maps.ControlPosition.LEFT_CENTER].push(mapFilterControlsDiv);

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.userPos = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    };
                    const userMarker = new google.maps.Marker({
                        position: this.userPos,
                        animation: google.maps.Animation.DROP,
                        icon: this.icons["user"],
                        map: this.map,
                    });
                    const userInfoWindow = new google.maps.InfoWindow({map: this.map});
                    userInfoWindow.setContent(
                        `<div class="text-center"><strong>You are here.</strong><br />${this.userPos.lat}, ${this.userPos.lng}</div>`
                    );
                    userMarker.addListener("click", () => {
                        userInfoWindow.open(this.map, userMarker);
                    });
                    if (!this.singleSpot) this.map.setCenter(this.userPos);
                },
                () => {
                    this.handleLocationError(true, this.infoWindow, this.map.getCenter());
                }
            );
        } else {
            this.handleLocationError(false, this.infoWindow, this.map.getCenter());
        }

        google.maps.event.addListener(this.map, "click", (event) => {
            this.placeNewMarker(event.latLng);
        });
    }

    async initMarkerCluster() {
        if (this.markers.length > 0) {
            this.markerCluster = new MarkerClusterer({
                map: this.map,
                markers: this.markers
            });
        } else {
            console.warn("No markers available for clustering.");
        }
    }

    handleLocationError(browserHasGeolocation, infoWindow, userPos) {
        infoWindow.setPosition(userPos);
        infoWindow.setContent(
            browserHasGeolocation
                ? "Error: The Geolocation service failed."
                : "Error: Your browser doesn't support geolocation."
        );
    }

    populateInfoWindow(marker, infowindow) {
        if (infowindow.marker !== marker) {
            const markerTypeMap = {
                free_spot: "Free Spot",
                paid_spot: "Paid Spot",
                campsite: "Campsite",
                mtb_spot: "MTB Spot",
                climbing_spot: "Climbing Spot",
                kayaking_spot: "Kayaking Spot",
                surf_spot: "Surf Spot",
                bad_spot: "Bad Spot",
            };
            const markerType = markerTypeMap[marker.type] || "Unknown Spot Type";
            const infoWindowContent = `
        <div id="content">
          <h2 id="infoWindowHeading" class="infoWindowHeading">
            <a href="/spots/${marker.id}">${marker.name}</a>
          </h2>
          <div id="infoWindowContent" class="infoWindowContent">
            <h6>${markerType} - ${marker.average_rating}/10</h6>
            <p>${marker.description}</p>
            <p>
              <a class="btn btn-sm btn-secondary" href="https://www.google.com/maps/dir/?api=1&destination=${marker.position.lat()},${marker.position.lng()}">Directions</a>
              <a class="btn btn-sm btn-info" href="/spots/${marker.id}">More Info</a>
            </p>
          </div>
        </div>`;
            infowindow.marker = marker;
            infowindow.setContent(infoWindowContent);
            infowindow.open(this.map, marker);
            infowindow.addListener("closeclick", () => {
                infowindow.marker = null;
            });
        }
    }

    placeNewMarker(location) {
        if (this.newMarker) {
            this.newMarker.setPosition(location);
        } else {
            this.newMarker = new google.maps.Marker({
                position: location,
                icon: "/assets/map-marker-lighter-ink.png",
                map: this.map,
            });
        }
        const newMarkerInfoWindowContent = `
      <div id="content">
        <a href="/spots/new?latitude=${location.lat()}&longitude=${location.lng()}"><strong> Add Spot Here </strong></a>
        <br />Lat: ${location.lat()}, <br />Lng: ${location.lng()}
      </div>`;
        this.newMarkerInfoWindow.setContent(newMarkerInfoWindowContent);
        this.newMarkerInfoWindow.open(this.map, this.newMarker);
        this.newMarker.addListener("click", () => {
            this.newMarkerInfoWindow.open(this.map, this.newMarker);
        });
    }

    showListings() {
        const bounds = new google.maps.LatLngBounds();
        this.markers.forEach((marker) => {
            marker.setMap(this.map);
            this.markerCluster.addMarker(marker);
            bounds.extend(marker.position);
        });
        this.map.fitBounds(bounds);
        this.markerCluster.repaint();
    }

    hideListings() {
        this.markers.forEach((marker) => {
            marker.setMap(null);
            this.markerCluster.removeMarker(marker);
        });
    }

    MapFilterControls(controlDiv, map) {
        const showAllUI = document.createElement("div");
        showAllUI.id = "showAllUI";
        showAllUI.title = "Show all listings";
        controlDiv.appendChild(showAllUI);

        const showAllText = document.createElement("div");
        showAllText.id = "showAllText";
        showAllText.innerHTML = "Show All";
        showAllUI.appendChild(showAllText);

        const hideAllUI = document.createElement("div");
        hideAllUI.id = "hideAllUI";
        hideAllUI.title = "Hide all listings";
        controlDiv.appendChild(hideAllUI);

        const hideAllText = document.createElement("div");
        hideAllText.id = "hideAllText";
        hideAllText.innerHTML = "Hide All";
        hideAllUI.appendChild(hideAllText);

        showAllUI.addEventListener("click", this.showListings.bind(this));
        hideAllUI.addEventListener("click", this.hideListings.bind(this));
    }
}
