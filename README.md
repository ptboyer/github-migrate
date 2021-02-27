Requires `env` variables, can be stored in `.env` file, see below:

```shell
USER=<github-username>
TOKEN=<github-access-token>
```

If a `mailmap` file is given will be used to ensure email is masked with given.

Example `mailmap` file. Get your masked github email from profile page.

```
First Last <0000000+username@users.noreply.github.com> First Last <first.last.personal.email@gmail.com>
```

To use, give url (used to `git clone` a repo) of the SOURCE repo to be migrated.

```shell
$ ./migrate.sh <git-clone-ssh-url>
```

If using `.env` file, run using:

```shell
$ env $(cat .env 2>/dev/null) ./migrate.sh <git-clone-ssh-url>
```
