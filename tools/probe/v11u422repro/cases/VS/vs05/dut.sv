// § strNetRefMintsNet422
// a strength net written by an assign (left side) and read by a gate
module top(input d, g, output o);
  trireg (large) c;
  assign c = d;
  nmos n1 (o, c, g);
endmodule
