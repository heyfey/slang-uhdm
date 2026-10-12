// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package pq; typedef struct packed { pk::w_t a; logic b; } s_t; endpackage
module sub (input pq::s_t i, output logic [2:0] o);
  assign o = i.a;
endmodule
module dut (input pq::s_t i, output logic [2:0] o);
  sub u (.i(i), .o(o));
endmodule
