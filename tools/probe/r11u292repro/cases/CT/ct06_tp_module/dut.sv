// § castTypeParamDefaultLoc292
module top #(type T = int) (output int o);
  assign o = T'(3);
  always_comb begin : b
    int k;
    k = T'(5);
  end
endmodule
