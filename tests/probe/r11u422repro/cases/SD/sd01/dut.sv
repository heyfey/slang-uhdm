// § strNetRefMintsNet422
module top(input d, g);
  trireg (large) cap1;
  nmos n1 (cap1, d, g);
endmodule
