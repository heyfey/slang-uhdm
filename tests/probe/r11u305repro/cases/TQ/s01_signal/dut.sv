// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [2:0] i, output logic [2:0] o);
  pk::w_t x;
  assign x = i;
  assign o = x;
endmodule
