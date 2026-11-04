// § strNetRefMintsNet422
// a scalar strength net read through a part of a concatenation and a bit-select of a vector
module top(input d, g, input [1:0] v, output [1:0] o);
  trireg (large) c;
  assign o = {c, v[0]};
  nmos n1 (c, d, g);
endmodule
