# git-url

## how to use
```
$ git-url [filepath] [line no]
```

## setting
`~/.ssh_config`
```
Host github.com
	HostName github.com
	User git
	SendEnv WEB_URL github.com:443
```
