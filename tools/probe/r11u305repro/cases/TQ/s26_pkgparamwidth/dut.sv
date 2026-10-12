// § scopedSimpleTdMemberBindsListing305
package pk; parameter int W = 3; typedef logic [W-1:0] w_t; endpackage
package pq; typedef struct packed { pk::w_t a; logic b; } s_t; endpackage
module dut (input logic [3:0] i, output logic [3:0] o);
  pq::s_t x;
  assign x = i;
  assign o = x;
endmodule
