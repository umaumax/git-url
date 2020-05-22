# git-url

## how to use
```
$ git-url [filepath] [line number]
```

## setting example
`~/.ssh/config`
```
Host github.com
  HostName github.com
  User git
  IdentityFile XXX
# SendEnv WEB_URL github.com

Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile XXX
# SendEnv WEB_URL gitlab.com
```

`WEB_URL` is used for custom url
