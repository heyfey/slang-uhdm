// § hpMacroSelDispExpanded428
`define OFF 4
typedef struct packed { logic [31:0] data; } pkt_t;
module top(input pkt_t p, output [1:0][7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = p.data[-`OFF+8*(i+1)-:4];
  end
endmodule
