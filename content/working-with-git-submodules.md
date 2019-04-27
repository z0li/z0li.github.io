---
title: "Working with git submodules"
date: 2019-04-27T20:20:42+02:00
---

Adding a new submodule to your git repository:

{{< highlight shell >}}
$ git submodule add https://github.com/z0li/hyde.git themes/hyde
{{< / highlight >}}

Initializing the git submodules in a freshly cloned repository:

{{< highlight shell >}}
$ git submodule update --init
{{< / highlight >}}

After this your submodules will be in a detached HEAD state. You can pull the latest updates from the remote master with:

{{< highlight shell >}}
$ git submodule update --remote
{{< / highlight >}}

And finally, you can commit and push the changes to the main repository:

{{< highlight shell >}}
$ git add themes/hyde
$ git commit -m "Moved themes/hyde submodule to track the latest commit"
$ git push
{{< / highlight >}}