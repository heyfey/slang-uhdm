// § genForCompoundStep424
module top (output logic [3:0][3:0] o);
  for (genvar i = 0; i < 4; i += 1) begin : g
    for (genvar j = 0; j < 4; j += 2) begin : h
      assign o[i][j] = 1'b1;
    end
  end
endmodule
