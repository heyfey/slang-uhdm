// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package q; typedef struct packed { pk::w_t a; logic b; } s_t; endpackage
module sub #(parameter type T = q::s_t) (output T o); assign o = '0; endmodule
module dut (output q::s_t o);
  sub u (o);
endmodule
