// § genCaReplWholeFold78 (decode only, ground B's ModuleEmit: Earlgrey #600811 / #530951) (if-generate, whole right side replication of a sized literal by a typed parameter: Earlgrey #600811 / #530951)
module m #(parameter int TotalWidth = 32, parameter bit E = 1) (output logic [7:0] q);
  if (E) begin : gen_secded
    logic [7:0] w;
    assign w = {TotalWidth{1'b1}};
    assign q = w;
  end else begin : gn
    assign q = '0;
  end
endmodule
module top(output logic [7:0] q);
  m #(.TotalWidth(8)) u (.*);
endmodule
