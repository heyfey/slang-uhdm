// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [3:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  typedef s_t s2_t;
  s2_t v;
  assign v = '0;
  assign o = v;
endmodule
