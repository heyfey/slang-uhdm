// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic clk, input logic p, output s_t [1:0] sd);
  localparam D = 2;
  always_ff @(posedge clk) sd[D-1].v <= p;
endmodule
