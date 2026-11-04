// § strNetRefMintsNet422
// two instances of a module holding a strength net read by a gate and $display
module cl(input d, g);
  trireg (large) cap;
  nmos n1 (cap, d, g);
  initial $display(cap);
endmodule
module top(input d, g);
  cl a(d, g);
  cl b(.d(d), .g(g));
endmodule
