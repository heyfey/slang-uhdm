// § scopedSimpleTdMemberBindsListing305
package pk; typedef bit w_t; endpackage
module dut (input logic i, output logic o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x;
  assign x = {i, i};
  assign o = x.a;
endmodule
