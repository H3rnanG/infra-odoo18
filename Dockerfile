FROM odoo:18.0

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    postgresql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN if [ -s /tmp/requirements.txt ]; then pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt; fi && \
    rm -f /tmp/requirements.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
