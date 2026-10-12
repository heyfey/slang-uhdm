// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package q;
  typedef struct packed { pk::w_t a; logic b; } s_t;
endpackage
module dut (input q::s_t i, output logic [2:0] o);
  q::s_t x;
  assign x = i;
  assign o = x.a;
endmodule
