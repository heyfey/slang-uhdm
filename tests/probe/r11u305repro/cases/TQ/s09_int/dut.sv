// § scopedSimpleTdMemberBindsListing305
package pk; typedef int w_t; endpackage
module dut (input logic [32:0] i, output logic [32:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
