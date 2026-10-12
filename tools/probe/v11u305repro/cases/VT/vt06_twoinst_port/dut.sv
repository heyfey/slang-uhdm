// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package q;
  typedef struct packed { pk::w_t a; logic b; } s_t;
endpackage
module sub (input q::s_t i, output logic [2:0] o); assign o = i.a; endmodule
module dut (input q::s_t i, output logic [5:0] o);
  sub s0 (i, o[2:0]);
  sub s1 (i, o[5:3]);
endmodule
