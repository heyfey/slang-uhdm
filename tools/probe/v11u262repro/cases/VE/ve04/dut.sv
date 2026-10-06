// § impConcatShareSameDecl262v (the second package imports the first and declares its own concatenation parameter of the same name; the module imports both)
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t E = '{a : 3, b : 4};
  parameter s_t [1:0] ALL = {E, D};
endpackage
package q;
  import p::*;
  parameter s_t [1:0] ALL = {D, E};
  localparam int QW = 2;
endpackage
module top import p::*; import q::*; (output integer o);
  assign o = QW + p::ALL[0].a;
endmodule
