// § scopedSimpleTdMemberBindsListing305
package pk; typedef integer w_t; endpackage
module dut (input logic [31:0] i, output logic [31:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x;
  assign x.a = i;
  assign x.b = 1'b0;
  assign o = x.a;
endmodule
