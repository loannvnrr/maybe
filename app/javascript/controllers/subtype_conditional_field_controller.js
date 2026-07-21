import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="subtype-conditional-field"
// Shows/hides a field (e.g. interest rate) depending on the selected account subtype.
export default class extends Controller {
  static targets = ["select", "field"];
  static values = { subtypes: Array };

  connect() {
    this.toggle();
  }

  toggle() {
    const visible = this.subtypesValue.includes(this.selectTarget.value);
    this.fieldTargets.forEach((field) => field.classList.toggle("hidden", !visible));
  }
}
