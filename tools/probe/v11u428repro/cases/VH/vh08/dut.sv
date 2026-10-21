// § hpMacroSelDispExpanded428
`define LG(a) $clog2(a)
typedef struct packed { logic [31:0] data; logic [3:0] sel; } pkt_t;
module dec #(parameter N = 2) (input [N-1:0] i, output o);
  assign o = |i;
endmodule
module top(input pkt_t p, output [1:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    dec #(.N(2)) d(.i(p.sel[i+:`LG(4)]), .o(y[i]));
  end
endmodule
