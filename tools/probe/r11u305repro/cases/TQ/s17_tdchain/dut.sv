// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; typedef w_t v_t; endpackage
module dut (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { pk::v_t a; logic b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
