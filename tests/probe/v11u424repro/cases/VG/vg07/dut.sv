// § genForCompoundStep424
module top (output logic [7:0] o);
  genvar i;
  for (i = 0; i < 8; i += 1) begin : g
    if (i % 2 == 0) begin : e
      assign o[i] = 1'b1;
    end else begin : od
      assign o[i] = 1'b0;
    end
  end
endmodule
