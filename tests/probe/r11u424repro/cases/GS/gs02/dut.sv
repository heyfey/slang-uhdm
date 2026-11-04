// § genForCompoundStep424
module top (output logic [7:0] o);
  genvar i, j;
  for (i = 0; i < 8; i += 2) begin : g
    assign o[i] = 1'b0;
  end
  for (j = 7; j > 0; j -= 2) begin : h
    assign o[j] = 1'b1;
  end
endmodule
