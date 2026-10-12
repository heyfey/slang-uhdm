// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [6:0] i, output logic [6:0] o);
  typedef struct packed { pk::w_t [1:0] a; logic b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
