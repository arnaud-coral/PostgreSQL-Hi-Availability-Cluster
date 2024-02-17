FROM postgres:12

# Install dependencies
RUN apt update && \
    apt install -y curl pipx python3-venv && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create and activate virtual environment then install PAtroni
RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install patroni[psycopg3,zookeeper]

# Create a non-root user 'patroni' with no password
# and change ownership of necessary directories
RUN useradd -m -s /bin/bash patroni

# Create necessary directories and change ownership
RUN mkdir /data /datalog && \
    chown -R patroni:patroni /opt/venv /data /datalog
    
USER patroni

# Expose ports for PostgreSQL and the Patroni REST API
EXPOSE 5432 8008

# Ensure the virtual environment is activated when the container starts
CMD ["/bin/bash", "-c", "source /opt/venv/bin/activate && patroni /etc/patroni.yml"]
