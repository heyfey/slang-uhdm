// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  typedef struct packed { logic [2:0] a; logic b; } s_t;
  s_t x;
  if (W > 1) begin : g
    assign y = $bits(x);
  end
endmodule
