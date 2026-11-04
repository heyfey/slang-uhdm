// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [3:0] i, output logic [3:0] o, output logic [3:0] p);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  typedef struct packed { logic b; pk::w_t a; } u_t;
  s_t x;
  u_t y;
  assign x = i;
  assign y = i;
  assign o = x;
  assign p = y;
endmodule
