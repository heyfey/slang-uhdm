// § ovrMultiDimConstUnparented131
// case o04: an overridden 2-D packed bit signed parameter, overridden positionally
module sub #(parameter bit signed [1:0][3:0] M = '0, parameter int K = 1) (output logic [7:0] o);
  assign o = M + K;
endmodule
module top(output logic [7:0] o);
  sub #(8'h3C, 2) u(.o(o));
endmodule
