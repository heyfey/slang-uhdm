// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] b_t; typedef b_t w_t; endpackage
module dut (output logic [2:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x.a;
endmodule
