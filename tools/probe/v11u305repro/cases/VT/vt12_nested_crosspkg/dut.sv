// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package q2;
  typedef struct packed { struct packed { pk::w_t a; } in; logic b; } s_t;
endpackage
module dut (input q2::s_t i, output logic [2:0] o);
  assign o = i.in.a;
endmodule
