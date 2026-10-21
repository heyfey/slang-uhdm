// § strNetRefMintsNet422
module top(input d, g);
  trireg (small) c2;
  trireg (large) c1;
  initial $display(c1, c2);
  nmos n1 (c1, d, g);
  nmos n2 (c2, d, g);
endmodule
