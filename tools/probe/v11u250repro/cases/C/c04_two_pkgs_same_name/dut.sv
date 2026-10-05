// § pkgArrTdListing250
// two packages each declaring a same-named array typedef, used from two modules and qualified side by side
package p;
  typedef logic [3:0] a_t [2];
endpackage
package q;
  typedef logic [7:0] a_t [4];
endpackage
module m1(output logic [3:0] o);
  import p::*;
  a_t v;
  assign v[0] = 4'd1;
  assign v[1] = 4'd2;
  assign o = v[1];
endmodule
module m2(output logic [7:0] o);
  import q::*;
  a_t v;
  p::a_t w;
  q::a_t x;
  assign v[3] = 8'd3;
  assign w[0] = 4'd4;
  assign x = v;
  assign o = x[3] + 8'(w[0]);
endmodule
module top(output logic [3:0] o1, output logic [7:0] o2);
  m1 a(.o(o1));
  m2 b(.o(o2));
endmodule
