// § gateInBitSelIndexSpan402
module top #(parameter I = 2)(output o, input [3:0] a, input b);
  and g1 (o, a[I], b, a[I-1]);
endmodule
