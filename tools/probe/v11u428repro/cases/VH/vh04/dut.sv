// § hpMacroSelDispExpanded428
`define W(n) ($clog2(n)+1)
typedef struct packed { logic [31:0] data; } pkt_t;
module top(input pkt_t p, output [1:0][7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = p.data[`W(8)*i+:4];
  end
endmodule
