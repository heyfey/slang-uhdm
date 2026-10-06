// § genLpFoldAddOperandKinds257v (an add on a bit-vector parameter whose value is a based decimal: the signed path, INT)
module common #(parameter int AW = 8, parameter int BW = 3, parameter bit [7:0] UW = 8'd5)(output logic [31:0] o);
  for (genvar g = 0; g < 1; ++g) begin : g_decoder
    localparam bit [UW+1:0] S = '1;
    assign o = 32'(S);
  end
endmodule
module top; logic [31:0] o; common u(.o(o)); endmodule
