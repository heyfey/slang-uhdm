// § impConcatParamShared262 (a concatenation of integer parameters: reduced, control)
package p;
  localparam int D = 1;
  localparam int E = 2;
  parameter logic [63:0] ALL = {E, D};
endpackage
package q;
  import p::*;
  localparam int QW = 2;
endpackage
module top import p::*; import q::*; (output integer o);
  assign o = QW;
endmodule
