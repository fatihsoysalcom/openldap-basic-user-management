#!/bin/bash

# This script demonstrates basic OpenLDAP user management tasks.
# It assumes a running OpenLDAP server with a base DN configured.

# --- Configuration ---
# Replace with your OpenLDAP server details
LDAP_HOST="ldap://localhost"
LDAP_PORT="389"
BASE_DN="dc=example,dc=com"
ROOT_DN="cn=admin,dc=example,dc=com"
ROOT_PASSWORD="adminpassword"

# --- Functions ---

# Function to add a user
add_user() {
    local uid="$1"
    local given_name="$2"
    local sn="$3"
    local user_password="$4"
    local dn="uid=$uid,ou=users,$BASE_DN"

    echo "Adding user: $uid"

    # Create LDIF file for adding user
    cat <<EOF > add_user.ldif
 dn: $dn
 objectClass: inetOrgPerson
 objectClass: organizationalPerson
 objectClass: person
 objectClass: top
 cn: $given_name $sn
 sn: $sn
 givenName: $given_name
 uid: $uid
 userPassword: $user_password
EOF

    # Use ldapadd to add the user
    ldapadd -H "$LDAP_HOST:$LDAP_PORT" -D "$ROOT_DN" -w "$ROOT_PASSWORD" -f add_user.ldif

    if [ $? -eq 0 ]; then
        echo "User $uid added successfully."
    else
        echo "Failed to add user $uid."
    fi
    rm add_user.ldif
}

# Function to search for a user
search_user() {
    local uid="$1"
    local filter="(uid=$uid)"

    echo "Searching for user: $uid"

    # Use ldapsearch to find the user
    ldapsearch -H "$LDAP_HOST:$LDAP_PORT" -D "$ROOT_DN" -w "$ROOT_PASSWORD" -b "ou=users,$BASE_DN" "$filter"
}

# Function to delete a user
delete_user() {
    local uid="$1"
    local dn="uid=$uid,ou=users,$BASE_DN"

    echo "Deleting user: $uid"

    # Use ldapdelete to remove the user
    ldapdelete -H "$LDAP_HOST:$LDAP_PORT" -D "$ROOT_DN" -w "$ROOT_PASSWORD" "$dn"

    if [ $? -eq 0 ]; then
        echo "User $uid deleted successfully."
    else
        echo "Failed to delete user $uid."
    fi
}

# --- Main Execution ---

# Ensure necessary tools are available
command -v ldapadd >/dev/null 2>&1 || { echo >&2 "ldapadd is required but not installed. Aborting."; exit 1; }
command -v ldapsearch >/dev/null 2>&1 || { echo >&2 "ldapsearch is required but not installed. Aborting."; exit 1; }
command -v ldapdelete >/dev/null 2>&1 || { echo >&2 "ldapdelete is required but not installed. Aborting."; exit 1; }

# Example Usage:

# 1. Add a user
add_user "jdoe" "John" "Doe" "secretpassword123"

# 2. Search for the user
search_user "jdoe"

# 3. Add another user
add_user "asmith" "Alice" "Smith" "anothersecurepass"

# 4. Search for the second user
search_user "asmith"

# 5. Delete the first user
delete_user "jdoe"

# 6. Attempt to search for the deleted user (should yield no results)
search_user "jdoe"

exit 0
