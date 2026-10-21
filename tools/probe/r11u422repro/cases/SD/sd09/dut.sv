// § strNetRefMintsNet422
module top(input d, g);
  trireg (large) c;
  nmos (c, d, g);
  initial $display(c);
endmodule
