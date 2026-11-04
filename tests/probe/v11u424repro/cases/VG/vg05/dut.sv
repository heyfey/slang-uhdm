// § genForCompoundStep424
module top (output logic [7:0] o);
  genvar i;
  for (i = 8; i > 0; i /= 2) begin : g
    assign o[i-1] = 1'b1;
  end
endmodule
