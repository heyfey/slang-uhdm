// § strNetRefMintsNet422
module top(input a, d, g, output o);
  trireg (large) c;
  wire x;
  assign x = a;
  nmos n1 (c, d, g);
  assign o = c;
  initial $display(c, x);
endmodule
