// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module mid #(parameter int N = 2) (input logic i);
  if (1) begin : g
    leaf l [N] (.i(i), .o());
  end
endmodule
module top (input logic i);
  mid #(.N(2)) m0 (.i(i));
  mid #(.N(3)) m1 (.i(i));
endmodule
