// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [3:0] i, output logic [2:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  assign o = s_t'(i).a;
endmodule
