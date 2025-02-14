export default {
  ThemeToggle: {
    mounted() {
      const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

      this.el.addEventListener('change', ev => {
        fetch('/session', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify({theme_toggle: this.el.checked})
        })
      })
    }
  }
}
