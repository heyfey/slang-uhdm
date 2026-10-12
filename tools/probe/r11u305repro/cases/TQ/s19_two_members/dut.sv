// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [5:0] i, output logic [5:0] o);
  typedef struct packed { pk::w_t a; pk::w_t b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
