// § impConcatParamShared262 (the importer is an instance at depth 1 with a select of the concatenation)
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t E = '{a : 3, b : 4};
  parameter s_t [1:0] ALL = {E, D};
endpackage
package q;
  import p::*;
  localparam int QW = 2;
endpackage
module m import p::*; import q::*; #(parameter int K = 1, localparam s_t P = ALL[K]) (output integer o);
  assign o = P.a + QW;
endmodule
module top(output integer o);
  m u (.o(o));
endmodule
