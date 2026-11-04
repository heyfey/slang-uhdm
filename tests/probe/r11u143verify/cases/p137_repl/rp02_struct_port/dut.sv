// § connReplTsRefThroughPort137
// case rp02: a constant replication connected to a packed-struct port, count from a localparam
package rp; typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t; endpackage
module sub(input rp::s_t s, output logic [7:0] o); assign o = s; endmodule
module top(output logic [7:0] o);
  localparam int N = 2;
  sub u(.s({N{4'hC}}), .o(o));
endmodule
