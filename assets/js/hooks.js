let paginate_el = null

const navigate = function(ev) {
  //pp("PageNav.navigate")

  if (ev.isTrusted) {
    const pos = paginate_el.getBoundingClientRect()
    //pp("PageNav.click", ev.x)

    if (ev.x < pos.left) {
      document.querySelector(".page-prev").click()
    } else if (ev.x > pos.right) {
      document.querySelector(".page-next").click()
    }
  }
}

export const Hooks = {
  PageNav: {
    mounted() {
      pp("PageNav.mounted")
      paginate_el = this.el
      window.addEventListener("click", navigate)
    },

    destroyed() {
      pp("PageNav.destroyed")
      window.removeEventListener("click", navigate)
    },

    updated() {
      pp("PageNav.updated")
    }
  }
}
