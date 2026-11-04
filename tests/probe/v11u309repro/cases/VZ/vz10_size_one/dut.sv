// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top (input logic i, output logic o);
  if (1) begin : g
    leaf l [1] (.i(i), .o(o));
  end
endmodule
