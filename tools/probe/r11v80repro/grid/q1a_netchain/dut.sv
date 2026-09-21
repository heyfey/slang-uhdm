// v11u80 q1a -- the ONE-HOP element NAME/net-type seam on the NET road,
// typedef CHAINS against their one-hop twins.
package pq1a;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;
  typedef sl_t sl2_t;
  typedef union packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef un_t un2_t;
  typedef logic [7:0] w_t;
  typedef w_t w2_t;
  wire  [7:0] q_nplain [0:1];
  wire  sl_t  q_nsl    [0:1];
  wire  sl2_t q_nsl2   [0:1];
  wire  un_t  q_nun    [0:1];
  wire  un2_t q_nun2   [0:1];
  wire  w_t   q_nw     [0:1];
  wire  w2_t  q_nw2    [0:1];
endpackage

module dut (output logic [31:0] o);
  import pq1a::*;
  assign o = {24'd0, q_nplain[0]} ^ {16'd0, q_nsl[0]} ^ {16'd0, q_nsl2[0]}
           ^ {16'd0, q_nun[0].a} ^ {16'd0, q_nun2[0].a}
           ^ {24'd0, q_nw[0]} ^ {24'd0, q_nw2[0]};
endmodule
