// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h5A) ();
  logic [7:0] a;
  logic [15:0] o;
  if (1) begin : g
    localparam int c = 8;
    assign o[c+:8] = a ^ ~M;
  end
endmodule
