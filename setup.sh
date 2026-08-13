#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting Odoo 18 project configuration...${NC}"

# 1. Create folder structure if it doesn't exist
echo "Creating directories..."
mkdir -p addons config postgresql odoo-web-data

# Generate random secure passwords for Odoo and Postgres
DB_PASSWORD=$(openssl rand -hex 16)
ADMIN_PASSWORD=$(openssl rand -hex 16)

# 2. Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "Copying .env.example to .env..."
    cp .env.example .env
    
    # Auto-replace passwords in .env
    sed -i "s/POSTGRES_PASSWORD=change_this_password/POSTGRES_PASSWORD=${DB_PASSWORD}/g" .env
    sed -i "s/ODOO_DB_PASSWORD=change_this_password/ODOO_DB_PASSWORD=${DB_PASSWORD}/g" .env
    sed -i "s/ODOO_ADMIN_PASSWORD=change_this_admin_password/ODOO_ADMIN_PASSWORD=${ADMIN_PASSWORD}/g" .env
    
    echo -e "${GREEN}.env file created with secure generated passwords!${NC}"
else
    echo ".env file already exists."
fi

# 3. Create config/odoo.conf from example if it doesn't exist
if [ ! -f config/odoo.conf ]; then
    echo "Copying config/odoo.conf.example to config/odoo.conf..."
    cp config/odoo.conf.example config/odoo.conf
    
    # Auto-replace credentials in config/odoo.conf
    sed -i "s/admin_passwd = CHANGE_ME/admin_passwd = ${ADMIN_PASSWORD}/g" config/odoo.conf
    sed -i "s/db_user = CHANGE_ME/db_user = odoo/g" config/odoo.conf
    sed -i "s/db_password = CHANGE_ME/db_password = ${DB_PASSWORD}/g" config/odoo.conf
    
    echo -e "${GREEN}config/odoo.conf file created with secure generated passwords!${NC}"
else
    echo "config/odoo.conf file already exists."
fi

# 4. Adjust permissions (critical for Docker on Linux/AWS)
echo "Adjusting data folder permissions..."
chmod +x setup.sh entrypoint.sh 2>/dev/null || true
chmod -R 777 postgresql odoo-web-data

echo -e "${GREEN}Configuration completed!${NC}"
echo "You can now start the project with: docker compose up -d"
