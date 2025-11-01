# ---------- build: compila el binario ----------
FROM rust:1.81 AS build
WORKDIR /app
COPY . .
# Ajusta el nombre del binario si no se llama 'flutteractixapp'
RUN cargo build --release

# ---------- final: runtime Lambda (provided.al2) ----------
FROM public.ecr.aws/lambda/provided:al2

# (opcional) instala curl para bajar el adapter
RUN yum install -y curl && yum clean all

# Copia el binario compilado
COPY --from=build /app/target/release/flutteractixapp /usr/local/bin/flutteractixapp

# Descarga el AWS Lambda Web Adapter (última versión estable)
RUN curl -L -o /opt/bootstrap \
  https://github.com/awslabs/aws-lambda-web-adapter/releases/latest/download/aws-lambda-adapter \
  && chmod +x /opt/bootstrap

# El adapter envuelve tu servidor HTTP
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/bootstrap
# Tu app Actix debe escuchar en este puerto y en 0.0.0.0
ENV PORT=8000

# Arranque
CMD ["/usr/local/bin/flutteractixapp"]
