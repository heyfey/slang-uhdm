// § caFoldParentUnboundLhs267
module fc #(parameter int W = 4) (output logic [3:0] a, output logic [3:0] b);
  assign {a, b} = {2*W{1'b1}};
endmodule
module top(output logic [3:0] a, output logic [3:0] b);
  fc u_fc(.a(a), .b(b));
endmodule
