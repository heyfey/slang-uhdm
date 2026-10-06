// § impConcatParamShared262 (a concatenation with a literal member and a replication)
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  parameter s_t [2:0] ALL = {D, {2{D}}};
endpackage
package q;
  import p::*;
  localparam int QW = 2;
endpackage
module top import p::*; import q::*; (output integer o);
  assign o = QW;
endmodule
