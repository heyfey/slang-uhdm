// § ndaSysCallNetTs212 — verifier: a net declaration assignment of a signing cast with an interconnect-free user net type (a packed struct net)
typedef struct packed { logic [2:0] a; logic b; } s_t;
module dut (input logic signed [3:0] i, output logic [3:0] o);
  wire s_t w = unsigned'(i);
  assign o = w;
endmodule
