// § impConcatParamShared262 (the module imports the re-listing package first)
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
module top import q::*; import p::*; (output integer o);
  assign o = QW;
endmodule
