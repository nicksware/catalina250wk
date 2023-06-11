document.querySelector('nav h2').addEventListener('click', () => {
    const menu = document.querySelector('nav ul');
    if (window.innerWidth <= 1100) {
        menu.style.display = menu.style.display == 'block' ? 'none' : 'block';
    }
});
