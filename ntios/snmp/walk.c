#include <stdio.h>
#include <stdlib.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>

//This program finds an SNMP device that contains a particular oid.
//gcc -o walk  walk.c -lnetsnmp 

int find_snmp_device(const char *ip, const char *oid, int retries);

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        fprintf(stderr, "Usage: %s <IP address> <OID>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *ip = argv[1];
    const char *oid = argv[2];
    return find_snmp_device(ip, oid, 5);
}

int find_snmp_device(const char *ip, const char *oid, int retries)
{
    netsnmp_session session, *ss;
    netsnmp_pdu *pdu, *response;
    uint8_t anOID[MAX_OID_LEN];
    size_t anOID_len;

    netsnmp_variable_list *vars;
    int status;

    // Initialize the SNMP library
    init_snmp("snmpwalk");

    // Initialize a session
    snmp_sess_init(&session);
    session.peername = strdup(ip);
    session.version = SNMP_VERSION_2c;
    session.community = "public";
    session.community_len = strlen(session.community);
    session.timeout = 1000;

    // Open the session
    ss = snmp_open(&session);
    if (!ss)
    {
        fprintf(stderr, "Error: Unable to open SNMP session.\n");
        exit(EXIT_FAILURE);
    }

    // Build the SNMP PDU
    pdu = snmp_pdu_create(SNMP_MSG_GETNEXT);
    anOID_len = MAX_OID_LEN;
    if (!snmp_parse_oid(oid, (long unsigned int *) anOID, &anOID_len))
    {
        fprintf(stderr, "Error: Unable to parse OID '%s'.\n", oid);
        exit(EXIT_FAILURE);
    }
    snmp_add_null_var(pdu, (const long unsigned int *) anOID, anOID_len);

    // Send the SNMP PDU 5 times
    for (int i = 0; i < retries; i++)
    {
        status = snmp_synch_response(ss, pdu, &response);
        switch (status)
        {
        case STAT_SUCCESS:
            break;
        default:
            if (i = retries - 1){
                return EXIT_FAILURE;
            }
            usleep(500*1000);
            continue;
        }
        break;
    }

    // Check the response
    if (response->errstat == SNMP_ERR_NOERROR)
    {
        for (vars = response->variables; vars; vars = vars->next_variable)
        {
            char oid_str[MAX_OID_LEN];
            size_t oid_str_len = MAX_OID_LEN;
            snprint_objid(oid_str, oid_str_len, vars->name, vars->name_length);
            if (oid_str[0] == 'i' && oid_str[1] == 's' && oid_str[2] == 'o')
            {
                oid_str[0] = ' ';
                oid_str[1] = ' ';
                oid_str[2] = '1';
            }
            printf("OID: %s\n", oid_str+2);
            if(strstr(oid_str+2, oid) == NULL)
            {
                return EXIT_FAILURE;
            }
            else {
                return EXIT_SUCCESS;
            }
        }
    }
    else
    {
        fprintf(stderr, "Error: SNMP request failed.\n");
        exit(EXIT_FAILURE);
    }

    // Clean up
    snmp_close(ss);
    snmp_shutdown("snmpwalk");
    return EXIT_FAILURE;
}