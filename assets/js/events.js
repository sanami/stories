window.addEventListener("phx:set_page_url", (ev) => {
  pp("set_page_url", ev.detail)
  const url = ev.detail.url
  if (url) {
    window.history.pushState({}, "", url);
  }
})

window.addEventListener("phx:reset_scroll", (ev) => {
  pp("reset_scroll", ev.detail)
  const el = document.querySelector(ev.detail.element)
  if (el) {
    el.scrollTop = 0
  }
})
