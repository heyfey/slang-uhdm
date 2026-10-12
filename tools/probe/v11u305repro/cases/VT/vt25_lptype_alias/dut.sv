// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [3:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  localparam type T2 = s_t;
  T2 v;
  assign v = '0;
  assign o = v;
endmodule
