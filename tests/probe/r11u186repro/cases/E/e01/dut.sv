// § aliasOfTdSharedKeepsModName183
package p;
typedef logic [7:0] byte_t;
typedef byte_t data_t;
typedef struct packed { data_t d; logic v; } pkt_t;
endpackage
module top (input p::pkt_t a, output logic [7:0] o);
  import p::*;
  assign o = a.d;
endmodule
