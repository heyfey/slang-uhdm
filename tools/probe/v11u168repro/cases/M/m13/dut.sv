// § ppOutputLine166
`define INST(n, a, y) \
  sub #( \
    .W(4) \
  ) n ( \
    .a(a), \
    .y(y) \
  );
module sub #(parameter W = 1) (input logic [W-1:0] a, output logic [W-1:0] y);
  assign y = ~a;
endmodule
module top(input logic [3:0] a, output logic [3:0] y);
  `INST(u, a, y)
endmodule
