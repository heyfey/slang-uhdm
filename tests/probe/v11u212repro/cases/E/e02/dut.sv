// § signCastSysCallLhsTs212 — verifier: an unsigned cast onto a variable of a packed struct typedef
typedef struct packed { logic [2:0] a; logic [3:0] b; } s_t;
module dut (input logic signed [6:0] i, output logic [6:0] o);
  s_t v;
  assign v = unsigned'(i);
  assign o = v;
endmodule
