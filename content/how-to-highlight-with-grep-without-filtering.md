---
title: "How to use grep to highlight matches without filtering out the rest"
date: 2019-04-21T15:59:12+02:00
tags: ["howto", "grep", "unix"]
---

Sometimes you wanna highlight certain keywords in a file and still see every line, not just the ones that are matching:

{{< highlight shell >}}
$ egrep --color 'hello|world|^' <filename>
{{< / highlight >}}
