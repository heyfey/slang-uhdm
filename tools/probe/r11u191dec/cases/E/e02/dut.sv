// (r11u191 N1082) the same ternary shapes as module parameters, one overridden by an instance
module m #(parameter int W = 4) (output int o);
  localparam int L = $clog2(W);
  localparam int S = W == 1 ? 1 : L;
  localparam int T = (W > 2) ? W : 2;
  assign o = S + T;
endmodule
module top(output int o1, output int o2);
  m u1(.o(o1));
  m #(.W(1)) u2(.o(o2));
endmodule
