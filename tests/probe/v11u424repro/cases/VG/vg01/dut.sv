// § genForCompoundStep424
module top (output logic [7:0] o);
  genvar i;
  for (i = 7; i >= 0; i -= 1) begin : g
    assign o[i] = 1'b0;
  end
endmodule
