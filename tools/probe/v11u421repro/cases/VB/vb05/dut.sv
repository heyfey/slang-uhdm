// § bitsDefNoFoldNoTs421
typedef struct packed { logic [3:0] d; logic b; } u_s;
module top ();
  u_s v;
  localparam W = $bits(v);
  logic [W-1:0] q;
endmodule
