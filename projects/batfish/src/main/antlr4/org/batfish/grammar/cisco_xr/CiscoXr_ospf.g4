parser grammar CiscoXr_ospf;

import CiscoXr_common;

options {
   tokenVocab = CiscoXrLexer;
}

ro_address_family
:
   ADDRESS_FAMILY IPV4 UNICAST? NEWLINE
;

ro_area
:
   AREA area = ospf_area NEWLINE ro_area_inner*
;

ro_area_inner
:
  ro_common
  | roa_interface
  | roa_mpls
  | roa_nssa
  | roa_range
;

ro_area_default_cost
:
   AREA ospf_area DEFAULT_COST cost = uint_legacy NEWLINE
;

ro_area_filterlist
:
   AREA area = ospf_area FILTER_LIST PREFIX list = variable
   (
      IN
      | OUT
   ) NEWLINE
;

ro_area_nssa
:
   AREA area = ospf_area NSSA
   (
      (
         default_information_originate = DEFAULT_INFORMATION_ORIGINATE
         (
            (
               METRIC metric = uint_legacy
            )
            |
            (
               METRIC_TYPE metric_type = uint_legacy
            )
         )*
      )
      | no_redistribution = NO_REDISTRIBUTION
      | no_summary = NO_SUMMARY
   )* NEWLINE
;

ro_area_range
:
   AREA area = ospf_area RANGE
   (
      (
         area_ip = IP_ADDRESS area_subnet = IP_ADDRESS
      )
      | area_prefix = IP_PREFIX
   )
   (
      ADVERTISE
      | NOT_ADVERTISE
   )?
   (
      COST cost = uint_legacy
   )? NEWLINE
;

ro_area_stub
:
   AREA area = ospf_area STUB
   (
      no_summary = NO_SUMMARY
   )* NEWLINE
;

roc_authentication
:
   AUTHENTICATION MESSAGE_DIGEST? NEWLINE
;

ro_auto_cost
:
   AUTO_COST REFERENCE_BANDWIDTH uint_legacy
   (
      GBPS
      | MBPS
   )? NEWLINE
;

// Statements that can appear in router, area, or interface contexts
ro_common
:
   roc_authentication
   | roc_cost
   | roc_distribute_list_in
   | roc_network
   | roc_passive
   | roc_priority
   | roc_null
;

ro_default_information
:
   DEFAULT_INFORMATION ORIGINATE
   (
      (
         METRIC metric = uint_legacy
      )
      |
      (
         METRIC_TYPE metric_type = uint_legacy
      )
      | ALWAYS
      | ROUTE_POLICY policy = route_policy_name
      | TAG uint_legacy
   )* NEWLINE
;

ro_default_metric
:
   NO? DEFAULT_METRIC metric = uint_legacy NEWLINE
;

ro_distance
:
   DISTANCE value = uint_legacy NEWLINE
;

roc_distribute_list_in
:
  DISTRIBUTE_LIST
  (
    rodl_acl_in
    | rodl_prefix_list_in
    | rodl_route_policy
  )
;

ro_distribute_list_out: DISTRIBUTE_LIST (rodl_acl_out | rodl_prefix_list_out);

rodl_acl_in: acl = access_list_name IN NEWLINE;

rodl_prefix_list_in: PREFIX_LIST pl = prefix_list_name IN NEWLINE;

// route-policies can't be used on outbound traffic
rodl_route_policy: ROUTE_POLICY rp = route_policy_name IN NEWLINE;

rodl_acl_out: acl = access_list_name OUT NEWLINE;

rodl_prefix_list_out: PREFIX_LIST pl = prefix_list_name OUT NEWLINE;

ro_max_metric
:
   MAX_METRIC ROUTER_LSA
   (
      (
         external_lsa = EXTERNAL_LSA external = uint_legacy?
      )
      | stub = INCLUDE_STUB
      |
      (
         on_startup = ON_STARTUP uint_legacy?
      )
      |
      (
         summary_lsa = SUMMARY_LSA summary = uint_legacy?
      )
      |
      (
         WAIT_FOR_BGP
      )
   )* NEWLINE
;

ro_maximum_paths
:
   (
      MAXIMUM_PATHS
      |
      (
         MAXIMUM PATHS
      )
   ) uint_legacy NEWLINE
;

roc_network: NETWORK ospf_network_type NEWLINE;

roa_nssa
:
   NSSA
   (
      (
         DEFAULT_INFORMATION_ORIGINATE
         (
            (
               METRIC uint_legacy
            )
            |
            (
               METRIC_TYPE UINT8
            )
         )*
      )
      | NO_REDISTRIBUTION
      | NO_SUMMARY
   )* NEWLINE
;

roc_null
:
   NO?
   (
      (
         AREA variable AUTHENTICATION
      )
      | AUTO_COST
      | BFD
      | CAPABILITY
      | DEAD_INTERVAL
      | DISCARD_ROUTE
      | FAST_REROUTE
      | GRACEFUL_RESTART
      | HELLO_INTERVAL
      |
      (
         IP
         (
            OSPF
            (
               EVENT_HISTORY
            )
         )
      )
      | ISPF
      | LOG
      | LOG_ADJ_CHANGES
      | LOG_ADJACENCY_CHANGES
      | MAX_LSA
      |
      (
         MAXIMUM
         (
            REDISTRIBUTED_PREFIXES
         )
      )
      | MESSAGE_DIGEST_KEY
      | MTU_IGNORE
      |
      (
         NO
         (
            DEFAULT_INFORMATION
         )
      )
      | NSF
      | NSR
      | SNMP
      | TIMERS
   ) null_rest_of_line
;

roc_passive: PASSIVE (ENABLE | DISABLE)? NEWLINE;

roc_priority: PRIORITY uint_legacy NEWLINE;

ro_redistribute
:
   REDISTRIBUTE (
      ror_routing_instance
      | ror_routing_instance_null
   )
;

ror_routing_instance
:
   rorri_protocol (
      METRIC metric = ospf_metric
      | METRIC_TYPE type = ospf_metric_type
      | ROUTE_POLICY policy = route_policy_name
      | TAG tag = route_tag_from_0
   )* NEWLINE
;

rorri_protocol
:
   BGP bgp_asn
   | CONNECTED
   | EIGRP eigrp_asn
   | STATIC
;

ror_routing_instance_null
:
   (OSPF | RIP) null_rest_of_line
;

ro_router_id
:
   ROUTER_ID ip = IP_ADDRESS NEWLINE
;

ro_summary_address
:
   SUMMARY_ADDRESS network = IP_ADDRESS mask = IP_ADDRESS NOT_ADVERTISE?
   NEWLINE
;

ro_vrf
:
   VRF name = variable NEWLINE
   (
      ro_max_metric
      | ro_redistribute
   )*
;

roc_cost
:
   COST cost = uint_legacy NEWLINE
;

roa_interface
:
   INTERFACE iname = interface_name NEWLINE ro_common*
;

roa_range
:
   RANGE prefix = IP_PREFIX
   (
      ADVERTISE
      | NOT_ADVERTISE
   )?
   (
      COST cost = uint_legacy
   )? NEWLINE
;

roa_mpls
:
  MPLS
  (
    rompls_ldp
    | roampls_traffic_eng
  )
;

roampls_traffic_eng: TRAFFIC_ENG NEWLINE;

rov3_address_family
:
   ADDRESS_FAMILY IPV6 UNICAST? NEWLINE rov3_common*
   (
      EXIT_ADDRESS_FAMILY NEWLINE
   )?
;

rov3_common
:
   rov3_null
;

rov3_null
:
   (
      AREA
      | AUTO_COST
      | BFD
      | COST
      | DEAD_INTERVAL
      | DEFAULT_INFORMATION
      | DISCARD_ROUTE
      | DISTANCE
      | FAST_REROUTE
      | GRACEFUL_RESTART
      | HELLO_INTERVAL
      | INTERFACE
      | LOG
      | LOG_ADJACENCY_CHANGES
      | MAX_METRIC
      | MAXIMUM
      | MAXIMUM_PATHS
      | MTU_IGNORE
      | NETWORK
      | NSSA
      | NSR
      | OSPFV3
      | PASSIVE
      | PASSIVE_INTERFACE
      | PRIORITY
      | RANGE
      | REDISTRIBUTE
      | ROUTER_ID
      | TIMERS
   ) null_rest_of_line
;

s_router_ospf
:
   ROUTER OSPF name = variable
   (
      VRF vrf = variable
   )? NEWLINE
   (
      ro_address_family
      | ro_area
      | ro_area_default_cost
      | ro_area_filterlist
      | ro_area_nssa
      | ro_area_range
      | ro_area_stub
      | ro_auto_cost
      | ro_common
      | ro_default_information
      | ro_default_metric
      | ro_distance
      | ro_distribute_list_out
      | ro_max_metric
      | ro_maximum_paths
      | ro_mpls
      | ro_redistribute
      | ro_router_id
      | ro_summary_address
      | ro_vrf
   )*
;

s_router_ospfv3
:
   ROUTER OSPFV3 procname = variable NEWLINE
   (
      rov3_address_family
      | rov3_common
   )*
;

ro_mpls
:
  MPLS
  (
    rompls_ldp
    | rompls_traffic_eng
  )
;

rompls_ldp
:
  LDP
  (
    rompls_ldp_auto_config
    | rompls_ldp_sync
    | rompls_ldp_sync_igp_shortcuts
  )
;

rompls_ldp_auto_config: AUTO_CONFIG NEWLINE;

rompls_ldp_sync: SYNC NEWLINE;

rompls_ldp_sync_igp_shortcuts: SYNC_IGP_SHORTCUTS NEWLINE;

rompls_traffic_eng: TRAFFIC_ENG rompls_traffic_eng_null;

rompls_traffic_eng_null
:
  (
    AUTOROUTE_EXCLUDE
    | IGP_INTACT
    | IDP_SYNC_UPDATE
    | MULTICAST_INTACT
    | ROUTER_ID
  ) null_rest_of_line
;

ospf_area: ip = IP_ADDRESS | num = uint32;

// 1-16777214
ospf_metric: metric = uint32;

// 1 or 2
ospf_metric_type: type = uint8;
