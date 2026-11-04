// § hpMacroSelDispExpanded428
`define SEL(a,b) {a,b}
`define OFF2 8
typedef struct packed { logic [31:0] data; } pkt_t;
module top(input pkt_t p, output [1:0][7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = p.data[(i ? `OFF2 : 0)+:4];
  end
endmodule
