// § impConcatParamShared262 (an interface imports both packages)
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
interface ifc import p::*; import q::*; ();
  integer o;
  assign o = QW;
endinterface
module top(output integer o);
  ifc i();
  assign o = i.o;
endmodule
