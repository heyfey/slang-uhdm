// § kwAliasDeclResolves250v
// two packages each with a real alias of the same bare name; declarators at the same line and column in two files named x.sv
package p;
  typedef real r_t;
  typedef r_t al_t;
endpackage
package q;
  typedef shortreal r_t;
  typedef real s_t;
  typedef s_t al_t;
endpackage
