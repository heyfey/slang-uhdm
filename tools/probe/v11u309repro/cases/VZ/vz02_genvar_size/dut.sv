// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top (input logic i);
  for (genvar k = 1; k < 3; k++) begin : gf
    leaf l [k+1] (.i(i), .o());
  end
endmodule
