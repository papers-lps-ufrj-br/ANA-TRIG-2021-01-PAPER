# Use official TeX Live image containing the full LaTeX suite
FROM texlive/texlive:latest

# Install make, ghostscript and other utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    ghostscript \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

# Default execution runs make with latexmk inside the container
CMD ["make", "run_latexmk"]
