# Pushing to github

Remember that github forces different keys for different projects, do not use your main ssh key or it will work only the first time.
Create a specific key for the project, load the public part, then force the use of that key when pushing.

```shell
GIT_SSH_COMMAND='ssh -i ~/.ssh/jean -o IdentitiesOnly=yes' git push -u origin main
```

