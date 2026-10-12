// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [2:0] i, output logic [2:0] o);
  typedef logic [5:0] w_t;
  typedef struct packed { pk::w_t a; w_t b; } s_t;
  s_t x;
  assign x = {i, 6'd0};
  assign o = x.a;
endmodule
