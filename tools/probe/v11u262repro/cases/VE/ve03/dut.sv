// § impConcatShareSameDecl262v (struct concatenation parameters of one name in two unrelated packages, different members; the module imports both)
package a;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t E = '{a : 3, b : 4};
  parameter s_t [1:0] ALL = {E, D};
endpackage
package b;
  typedef struct packed { integer x; integer y; } t_t;
  localparam t_t F = '{x : 5, y : 6};
  localparam t_t G = '{x : 7, y : 8};
  parameter t_t [1:0] ALL = {G, F};
endpackage
module top import a::*; import b::*; (output integer o);
  assign o = a::ALL[0].a + b::ALL[1].y;
endmodule
