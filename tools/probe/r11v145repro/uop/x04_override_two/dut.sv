// § unaryOperandParamOwnerName145
module c #(parameter logic [7:0] M = 8'h0f) (input logic [7:0] a, output logic [7:0] o);
  if (1) begin : g
    assign o[7:0] = a & ~M;
  end
endmodule
module dut(input logic [7:0] a, output logic [7:0] x, output logic [7:0] y);
  c #(.M(8'h33)) u0(a, x);
  c u1(a, y);
endmodule
