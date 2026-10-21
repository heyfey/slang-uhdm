// § genForCompoundStep424
module top (output logic [7:0] o);
  genvar i;
  for (i = 0; i < 8; i = i + 2) begin : g
    assign o[i] = 1'b1;
  end
endmodule
