export const Hooks = {
  StoryViewer: {
    updated() {
      // Reset scroll on story change
      this.el.scrollTop = 0
    }
  }
}
