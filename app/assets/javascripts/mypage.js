//= require jquery3
//= require popper
//= require rails-ujs
//= require bootstrap-material-design/dist/js/bootstrap-material-design.js

function previewFileWithId(id) {
  const target = this.event.target;
  const file = target.files[0];
  const reader  = new FileReader();
  reader.onloadend = function () {
    id.src = reader.result;
  }
  if (file) {
    reader.readAsDataURL(file);
  } else {
    id.src = "";
  }
}