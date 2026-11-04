// § hpDispPowerOneToken428
typedef struct packed { logic [31:0] data; logic [3:0] sel; } pkt_t;
module top(input pkt_t p, output [1:0][31:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = {(32/(8*(2**i))){p.data[0+:(8*(2**i))]}};
  end
endmodule
