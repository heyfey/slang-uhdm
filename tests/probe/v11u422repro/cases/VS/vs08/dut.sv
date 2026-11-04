// § strNetRefMintsNet422
// a strength vector net read whole by an assign and by a gate terminal
module top(input d, g, output [1:0] o);
  trireg (medium) [1:0] c;
  assign o = c;
  nmos n1 (c, d, g);
endmodule
