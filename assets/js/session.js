const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

window.addEventListener("phx:store_session", (ev) => {
  pp("store_session", ev.detail)

  fetch('/session', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify(ev.detail)
  })
})

window.store_session = function(data) {
  const ev = new CustomEvent("phx:store_session", {detail: data });
  window.dispatchEvent(ev);
}
