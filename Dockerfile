FROM node:15.5-alpine3.11

RUN set -x && \
  apk --update upgrade                                  &&  \
  apk add git bash                                      &&  \
  adduser -D -g git git                                 &&  \
  yarn global add git-http-server                       &&  \
  git config --system http.receivepack true             &&  \
  git config --system http.uploadpack true              &&  \
  git config --system user.email "gitserver@git.com"    &&  \
  git config --system user.name "Git Server"

ADD ./entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT [ "entrypoint" ]
CMD [ "git-http-server", "-p", "80", "/home/git" ]
