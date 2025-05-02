# Use the Alpine Linux base image
FROM alpine:latest

# Install required packages for LaTeX compilation and gnuplot
RUN apk update && apk add texlive-full gnuplot

# Set the working directory
WORKDIR /root

# Copy your LaTeX and gnuplot files to the container
COPY * /root

ADD results/* /root/results/

# Set the entrypoint to compile LaTeX and execute gnuplot
#ENTRYPOINT ["sh", "-c", "pdflatex main.tex && gnuplot script.gp"]
