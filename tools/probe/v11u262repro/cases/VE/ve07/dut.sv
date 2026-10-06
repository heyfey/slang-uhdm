// § impConcatShareSameDecl262v (struct concatenation in two unrelated packages, same struct shape and name; module imports both wildcard, reads one)
package a;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  parameter s_t [1:0] ALL = {D, D};
endpackage
package b;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 9, b : 8};
  parameter s_t [1:0] ALL = {D, D};
endpackage
module top import a::*; import b::*; (output integer o);
  assign o = b::ALL[1].b;
endmodule
