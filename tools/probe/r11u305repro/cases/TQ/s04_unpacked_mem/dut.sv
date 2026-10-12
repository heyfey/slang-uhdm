// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [2:0] i, output logic [2:0] o);
  typedef struct { pk::w_t a [2]; logic b; } s_t;
  s_t x;
  assign x.a[0] = i;
  assign o = x.a[0];
endmodule
