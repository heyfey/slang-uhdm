// § hpDispPowerOneToken428
typedef struct packed { logic [31:0] data; } pkt_t;
module top(input pkt_t p, output [1:0][7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = p.data[2**i];
  end
endmodule
