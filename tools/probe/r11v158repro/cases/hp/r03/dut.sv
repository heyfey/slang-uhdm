// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef struct packed { int W; int D; } cfg_t;
interface ifc; logic [7:0] adr; logic [7:0] dat; localparam int OFF = 2; endinterface
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}) (ifc sub, input logic clk, input logic i);
  s_t s, t; logic [3:0] q, q2; logic [7:0] q8; logic [7:0] v; logic [3:0] mem [0:15];
  function automatic logic [3:0] f(input logic [3:0] z); return z; endfunction
  always_comb begin
    q = '0;
    for (int k = 0; k < Cfg.D; k++) q[k] = s.a[k];
    case (s.b) 4'd1: q2 = sub.adr[3:0]; default: q2 = s.a; endcase
  end
endmodule
module tb; ifc bus(); top dut(.sub(bus), .clk(1'b0), .i(1'b0)); endmodule
