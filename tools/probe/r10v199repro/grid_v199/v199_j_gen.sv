package vpj;
  parameter J_UHEX = 'hf0;
  parameter J_UDEC = 4;
endpackage
import vpj::*;
module vj(input logic clk);
  generate
    if (J_UDEC > 1) begin : gblk
      import vpj::*;
      logic r;
      always_ff @(posedge clk) r <= 1'b0;
    end
  endgenerate
endmodule
