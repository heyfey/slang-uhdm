// § kwAliasDeclResolves250v
// a module-local typedef with the same name as a package alias-of-keyword, used by a variable in the same module
package p;
  typedef real r_t;
  typedef r_t al_t;
  typedef int i_t;
  typedef i_t j_t;
endpackage
module sub(output logic [7:0] o);
  typedef real al_t;
  typedef int j_t;
  al_t x;
  j_t k;
  initial begin x = 1.5; k = 2; end
  assign o = 8'(k);
endmodule
module top(output logic [7:0] o, output logic [7:0] o2);
  import p::*;
  al_t y;
  j_t z;
  initial begin y = 2.5; z = 3; end
  assign o2 = 8'(z);
  sub u(.o(o));
endmodule
