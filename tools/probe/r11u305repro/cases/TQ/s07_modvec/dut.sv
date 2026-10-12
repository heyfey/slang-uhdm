// § scopedSimpleTdMemberBindsListing305
module dut (input logic [3:0] i, output logic [3:0] o);
  typedef logic [2:0] w_t;
  typedef struct packed { w_t a; logic b; } s_t;
  s_t x;
  assign x = i;
  assign o = x;
endmodule
