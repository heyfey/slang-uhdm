// § hpMacroSelDispExpanded428
`define MAXV(a,b) (((a)>(b))?(a):(b))
typedef struct packed { logic [31:0] data; logic [3:0] sel; } pkt_t;
module dec #(parameter N = 2) (input [N-1:0] i, output o);
  assign o = |i;
endmodule
module top(input pkt_t p, output [1:0] y);
  localparam W = 4;
  for (genvar i = 0; i < 2; i++) begin: g
    dec #(.N(`MAXV(W-i,1))) d(.i(p.sel[i+:`MAXV(W-i,1)]), .o(y[i]));
  end
endmodule
