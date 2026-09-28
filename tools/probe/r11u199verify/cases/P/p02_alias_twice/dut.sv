// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned A; int unsigned B; } base_t;
  typedef base_t mid_t;
  typedef mid_t top_t;
  localparam top_t K = '{A:3, B:5};
  typedef struct packed { logic [K.A-1:0] a; logic [K.B-1:0] b; } pkt_t;
endpackage
module top import p::*; (input pkt_t i, output pkt_t o);
  assign o = i;
endmodule
