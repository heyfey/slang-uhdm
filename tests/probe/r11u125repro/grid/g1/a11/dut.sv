// § genvarParamFile125
module top #(parameter P = 1) (output [3:0] o);
  if (P) begin : c
    for (genvar i = 0; i < 4; i++) begin : g
      assign o[i] = 1'b1;
    end
  end
endmodule
