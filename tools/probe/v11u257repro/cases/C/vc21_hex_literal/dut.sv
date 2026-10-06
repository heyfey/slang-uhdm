// § genLpFoldAddOperandKinds257v (an add of an int parameter and a hex literal, and of a based decimal)
module common #(parameter int AW = 8)(output logic [31:0] o, output logic [31:0] o2);
  for (genvar g = 0; g < 1; ++g) begin : g_decoder
    localparam bit [AW+4'h1:0] S = '1; localparam bit [AW+4'd1:0] T = '1; assign o = 32'(S); assign o2 = 32'(T); end
endmodule
module top; logic [31:0] o, o2; common u(.o(o), .o2(o2)); endmodule
