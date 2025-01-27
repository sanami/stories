#Logger.configure level: :info

import_if_available Ecto.Query

alias App.{Repo, Stories}
alias App.Stories.{StoryCategory, StoryAuthor, Story, Loader}
