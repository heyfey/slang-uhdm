// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top (input logic [1:0] i, output logic [1:0] o);
  if (1) begin : g
    leaf l [2] (.i(i), .o(o));
  end
endmodule
