// § operatorAttrsListed403
module top();
  bit a, b, c, d;
  initial a = b ? (* no_glitch *) c : d;
  assign d = a & (* keep, mode = "x" *) b;
endmodule
