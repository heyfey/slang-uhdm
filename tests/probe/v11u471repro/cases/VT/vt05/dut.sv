// § impTdParamCaFoldTs471
// read in a sub module instantiated twice and in the parent
package a;
  typedef logic [4:0] w_t;
  parameter w_t PW = 5'd17;
endpackage
module sub(output logic [4:0] o);
  import a::*;
  assign o = PW + 5'd1;
endmodule
module top(output logic [4:0] y, output logic [4:0] z, output logic [4:0] w);
  import a::*;
  sub u1(.o(y));
  sub u2(.o(z));
  assign w = PW;
endmodule
