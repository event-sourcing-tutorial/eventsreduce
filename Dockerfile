FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y lsb-release wget gnupg2 supervisor
 
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
 
RUN apt update -y
RUN apt install -y postgresql-15
 
RUN cp /etc/postgresql/15/main/postgresql.conf /etc/postgresql/15/main/postgresql.conf.orig
RUN cp /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/main/pg_hba.conf.orig
 

RUN apt install -y curl gcc
RUN apt install -y protobuf-compiler libprotobuf-dev
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
RUN cargo install cargo-watch
RUN mkdir /app
COPY ./Cargo.toml /app/Cargo.toml
COPY ./Cargo.lock /app/Cargo.lock
#COPY ./build.rs /app/build.rs
COPY ./src /app/src
#COPY ./proto /app/proto


#COPY app.conf /etc/supervisor/conf.d/app.conf
COPY docker-entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
