// § unaryOperandParamOwnerName145
module dut #(parameter logic [3:0] M = 4'h3) (input logic [3:0] a, output logic [3:0] p, output logic [3:0] q);
  if (1) begin : g
    assign {p[3:0], q} = {a & ~M, a};
  end
endmodule
