export default {
  ThemeToggle: {
    mounted() {
      this.el.addEventListener('change', ev => {
        window.store_session({theme_toggle: this.el.checked})
      })
    }
  }
}
