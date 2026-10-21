// § genForCompoundStep424
module top (output logic [8:0] o);
  genvar i;
  for (i = 1; i < 9; i *= 2) begin : g
    assign o[i] = 1'b1;
  end
endmodule
