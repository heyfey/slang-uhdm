// § memberBareTdAliasNamedByUse183 (module importer, explicit import)
package p;
typedef bit [15:0] addr_t;
typedef struct { addr_t a; int k; } req_t;
endpackage
module top;
  import p::req_t;
  req_t r;
endmodule
