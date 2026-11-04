// § impConcatParamShared262 (three packages chained, the module imports all three)
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
package r;
  import q::*;
  localparam int RW = 3;
endpackage
module top import p::*; import q::*; import r::*; (output integer o);
  assign o = QW + RW;
endmodule
