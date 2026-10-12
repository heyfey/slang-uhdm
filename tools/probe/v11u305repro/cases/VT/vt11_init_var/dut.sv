// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [2:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t v = '{default: 0};
  assign o = v.a;
endmodule
