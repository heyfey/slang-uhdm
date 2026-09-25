typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef struct packed { int W; int D; } cfg_t;
interface ifc; logic [7:0] adr; logic [7:0] dat; localparam int OFF = 2; endinterface
module leaf(input logic [3:0] x, output logic [3:0] y); assign y = x; endmodule
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}, parameter bit B = 1) (ifc sub, input logic clk, input logic i);
  s_t s, t; logic [3:0] q, q2; logic [7:0] q8; logic [7:0] v; logic [3:0] mem [0:15];
  function automatic logic [3:0] f(input logic [3:0] z); return z; endfunction
  localparam int L1 = (Cfg.D > 2) ? Cfg.W : 1;
  localparam int L2 = B ? 1 : sub.OFF;
  localparam int L3 = B ? Cfg.D : Cfg.W;
endmodule
module tb; ifc bus(); top dut(.sub(bus), .clk(1'b0), .i(1'b0)); endmodule
