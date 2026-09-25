typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef struct packed { int W; int D; } cfg_t;
typedef struct { int DAT; int ADR; } bus_t;
typedef struct { bus_t BUS; int OFF; } big_t;
interface ifc; logic [7:0] adr; logic [7:0] dat; localparam int OFF = 2; endinterface
module leaf #(parameter int P = 1) (input logic [3:0] x, output logic [3:0] y); assign y = x; endmodule
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}, parameter big_t CFG = '{BUS: '{DAT: 32, ADR: 12}, OFF: 2}) (ifc sub, input logic clk, input logic i);
  s_t s, t; logic [3:0] q, q2; logic [7:0] q8; logic [7:0] v; logic [3:0] mem [0:15]; wire [3:0] w [0:15];
  function automatic int f(input int z); return z; endfunction
  always_comb begin
    v[Cfg.D-1:0] = 4'd0;
    v[7:Cfg.D] = 4'd1;
  end
endmodule
module tb; ifc bus(); top dut(.sub(bus), .clk(1'b0), .i(1'b0)); endmodule
