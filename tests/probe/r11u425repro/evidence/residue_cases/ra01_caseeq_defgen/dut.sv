// sister ground: TypeEmit mapSyntaxBinOp lacks CaseEquality/CaseInequality; the definition-view generate-block cont_assign drops the === condition (bsg_nonsynth_axi_mem's head)
module m #(parameter W=4)(input logic [W-1:0] ram [3:0], input [1:0] idx, output [W-1:0] o);
  logic [W-1:0] u;
  for (genvar i=0;i<W;i++) begin
    assign o[i] = (ram[idx][i] === 1'bx) ? u[i] : ram[idx][i];
  end
endmodule
module top(input logic [3:0] ram [3:0], input [1:0] idx, output [3:0] o);
  m u(.ram(ram), .idx(idx), .o(o));
endmodule
