// § anonAggElemKeywordTs247
package p;
  typedef struct { bit [3:0] pair [2]; byte q [2]; } ps_t;
endpackage
module top(input logic [3:0] a, output logic [3:0] o);
  import p::*;
  ps_t s;
  assign s.pair[0] = a;
  assign s.pair[1] = ~a;
  assign s.q[0] = {a, a}; assign s.q[1] = 0;
  assign o = s.pair[a[0]] ^ s.q[0][3:0];
endmodule
