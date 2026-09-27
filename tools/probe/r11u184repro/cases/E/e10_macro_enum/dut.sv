// § genLocalEnumConstShared184: a generate-block enum declared through a macro from an included file, read in the block's process
`include "defs.svh"
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  if (P) begin : g
    `DECL_ENUM(st_e, S0, S1)
    st_e q;
    always_ff @(posedge clk) q <= (q == S0) ? S1 : S0;
    always_comb y = (q == `PICK) ? 2'd1 : 2'd0;
  end
endmodule
