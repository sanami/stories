#Logger.configure level: :info

import_if_available Ecto.Query

alias Tex.{Repo, Stories}
alias Tex.Stories.{StoryCategory, StoryAuthor, Story, Loader}
