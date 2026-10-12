// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [3:0] i, output logic [3:0] o);
  struct packed { pk::w_t a; logic b; } x;
  assign x = i;
  assign o = x;
endmodule
