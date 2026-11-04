// § hpDispPowerOneToken428
typedef struct packed { logic [31:0] data; logic [3:0] sel; } pkt_t;
module top(input pkt_t p, output [7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i*4+:4] = p.data[i*4+:2**2];
  end
endmodule
