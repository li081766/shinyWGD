Shiny.addCustomMessageHandler("Success", success);
function success(message) {
    alert("Success. You can continue to the next step")
    alert(`run ${ message } successfully. You can continue to the next step`)
}

Shiny.addCustomMessageHandler("closeDropDownMenu", closeDropDownMenu);
function closeDropDownMenu(message) {
    const dropdownMenu = document.querySelector(".dropdown-menu");
    dropdownMenu.classList.remove("show");
    // dropdownMenu.style.display = "none";

    console.log(dropdownMenu);
    console.log("success");
}

Shiny.addCustomMessageHandler("toggleDropdown", toggleDropdown);
function toggleDropdown(msg) {
    console.log("start")
    $('.dropdown-menu').removeClass('show')
    console.log("done")
}
