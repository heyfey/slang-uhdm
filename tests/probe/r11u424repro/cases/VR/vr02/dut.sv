// § defGenConnVarSelRange424 (bsg_nonsynth_dramsim3 shape)
module m #(parameter w = 2) (input [w-1:0] a); endmodule
module top #(parameter aw = 8, parameter bo = 2) (input logic [1:0][aw-1:0] read_addr_li);
  genvar i;
  for (i = 0; i < 2; i++) begin : channels
    m #(.w(aw-bo)) u (.a(read_addr_li[i][aw-1:bo]));
  end
endmodule
