// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter int N = 1) (output logic [2:0] o);
  typedef struct packed { pk::w_t a; logic [N-1:0] b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x.a;
endmodule
module dut (output logic [5:0] o);
  sub #(1) s0 (o[2:0]);
  sub #(2) s1 (o[5:3]);
endmodule
