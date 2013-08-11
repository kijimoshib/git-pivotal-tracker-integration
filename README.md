# Git Tracker

`git-tracker` provides a set of additional Git commands to help developers when working with [Pivotal Tracker][pivotal-tracker] and [GitHub] [github].

[pivotal-tracker]: http://www.pivotaltracker.com


## Installation
`git-tracker` requires at least **Ruby 1.8.7** and **Git 1.8.2.1** in order to run.  It is tested against Rubies _1.8.7_, _1.9.3_, and _2.0.0_.  In order to install it, do the following:

```plain
$ gem install git-tracker
```


## Usage
`git-tracker` is intended to be a very lightweight tool, meaning that it won't affect your day to day workflow very much.  To be more specific, it is intended to automate branch creation and destruction as well as story state changes, but will not affect when you commit, when development branches are pushed to origin, etc.  The typical workflow looks something like the following:

```plain
$ git start       # Creates branch and starts story
$ git commit ...
$ git commit ...  # Your existing development process
$ git commit ...
$ git finish      # Merges and destroys branch, pushes to origin, and finishes story
```


## Configuration

### Git Client
In order to use `git-tracker`, two Git client configuration properties must be set.  If these properties have not been set, you will be prompted for them and your Git configuration will be updated.

| Name | Description
| ---- | -----------
| `pivotal.api-token` | Your Pivotal Tracker API Token.  This can be found in [your profile][profile] and should be set globally.
| `pivotal.project-id` | The Pivotal Tracker project id for the repository your are working in.  This can be found in the project's URL and should be set.

[profile]: https://www.pivotaltracker.com/profile


### Git Server
In order to take advantage of automatic issue completion, the [Pivotal Tracker Source Code Integration][integration] must be enabled.  If you are using GitHub, this integration is easy to enable by navgating to your project's 'Service Hooks' settings and configuring it with the proper credentials.

[integration]: https://www.pivotaltracker.com/help/integrations?version=v3#scm


## Commands

### `git start [ -t type | -s story-id | -a ]`
This command starts a story by creating a Git branch and changing the story's state to `started`.  This command can be run in a few ways.  First it can be run specifying the id of the story that you want to start.

```plain
$ git start -s 12345678
```

The second way to run the command is by specyifying the type of story that you would like to start.  In this case it will then offer you the first five stories (based on the backlog's order) of that type to choose from.

```plain
$ git start -t feature

1. Lorem ipsum dolor sit amet, consectetur adipiscing elit
2. Pellentesque sit amet ante eu tortor rutrum pharetra
3. Ut at purus dolor, vel ultricies metus
4. Duis egestas elit et leo ultrices non fringilla ante facilisis
5. Ut ut nunc neque, quis auctor mauris
Choose story to start:
```
Also, command can be run with filter -a.  In this case, it will then offer all stories (with all statuses) of any type.

Finally the command can be run without specifying anything.  In this case, it will then offer the first five stories (based on the backlog's order) of any type to choose from.

```plain
$ git start

1. FEATURE Donec convallis leo mi, dictum ornare sem
2. CHORE   Sed et magna lectus, sed auctor purus
3. FEATURE In a nunc et enim tincidunt interdum vitae et risus
4. FEATURE Fusce facilisis varius lorem, at tristique sem faucibus in
5. BUG     Donec iaculis ante neque, ut tempus augue
Choose story to start:
```

Once a story has been selected by one of the three methods, the command then prompts for the name of the branch to create.

```plain
$ git start -s 12345678
        Title: Lorem ipsum dolor sit amet, consectetur adipiscing elitattributes
  Description: Ut consequat sapien ut erat volutpat egestas. Integer venenatis lacinia facilisis.

Enter branch name (12345678/FEATURE_<branch-name>):
```

The value entered here will be prepended with the story id such that the branch name is `12345678/FEATURE_<branch-name>`.  This branch is then created and checked out.

### `git finish [-b base | -h head | --[no-]push]`
This command finishes a story by pushing the changes to a remote server and making pull-request. As well, this command will make a comment with the link of pull-request in the current history.
This command can be run in two ways. First it can be run without options.

```plain
$ git finish
Pushing to origin... OK
Creating pull-request on GutHub... OK
Add a new comment to current story... OK
Finishing story on Pivotal Tracker... OK
Pull request: https://github.com/kijimoshib/test_app/pull/26
```

The second way is with the `[-b base | -h head | --[no-]push]` option specified. In this case `finish` performs the same actions, but with different base and/or head branch. Also, option --[no-]push] can activate/deactivate making push to origin at start (activate for default).

### `git track [ -t type | -s story-id | -a ]`
This command is almost completely analogous to `start`, except that it does not start the story. It used only to display additional information.