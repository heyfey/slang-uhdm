// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [2:0] i, output logic [2:0] o);
  typedef union packed { pk::w_t a; logic [2:0] b; } u_t;
  u_t x;
  assign x = i;
  assign o = x;
endmodule
