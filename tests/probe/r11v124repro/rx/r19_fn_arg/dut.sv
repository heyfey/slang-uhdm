// § realLitValueIsText124
module top(output int o); function automatic int h(real x); return int'(x); endfunction assign o = h(4.5); endmodule
