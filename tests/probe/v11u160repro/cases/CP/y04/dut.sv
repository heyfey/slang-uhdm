// § implNetBareParamElab160
module g(); parameter int P = 1;
  if (P > 0) begin : gb
    assign o = P;
  end
endmodule
module top(); g #(.P(2)) u(); endmodule
