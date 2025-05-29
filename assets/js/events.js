window.addEventListener("phx:set-page-url", (ev) => {
  pp("set-page-url", ev.detail)

  const url = ev.detail.url
  if (url) {
    window.history.pushState({}, "", url);
  }
})

window.addEventListener("phx:reset-scroll", (ev) => {
  pp("reset-scroll", ev.detail)

  const el = document.querySelector(ev.detail.element)
  if (el) {
    el.scrollTop = 0
    el.scrollLeft = 0
  }
})

window.addEventListener("phx:scroll-into-view", (ev) => {
  pp("scroll-into-view", ev.detail)

  const el = document.querySelector(ev.detail.element)
  if (el) {
    if (ev.detail.if_needed) {
      el.scrollIntoViewIfNeeded(true)
    } else {
      const block = ev.detail.block || "center"
      el.scrollIntoView({block: block})
    }
  }
})
