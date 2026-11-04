// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [4:0] i, output logic [4:0] o);
  typedef struct packed { struct packed { pk::w_t a; logic c; } in; logic b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
