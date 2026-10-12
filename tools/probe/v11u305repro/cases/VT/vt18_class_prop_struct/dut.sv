// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
class C;
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t v;
endclass
module dut (output logic [2:0] o);
  C c;
  assign o = 3'd0;
endmodule
