// § realLitValueIsText124
module top(output real o); function automatic real h(real x); return x + 0.75; endfunction assign o = h(1.0); endmodule
