// § ppOutputLine166
`define FSM(st, nx) \
  always_comb begin \
    case (st) \
      2'd0: nx = 2'd1; \
      2'd1: nx = 2'd2; \
      default: nx = 2'd0; \
    endcase \
  end
module top(input logic clk, output logic [1:0] st);
  logic [1:0] nx;
  `FSM(st, nx)
  always_ff @(posedge clk) st <= nx;
endmodule
