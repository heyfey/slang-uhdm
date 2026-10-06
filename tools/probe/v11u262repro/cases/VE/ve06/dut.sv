// § impConcatShareSameDecl262v (one package re-listed through an importing package, plus an unrelated same-name concatenation; depth-1 instance)
package p;
  localparam logic [3:0] P1 = 4'h5;
  parameter logic [7:0] X = {P1, P1};
endpackage
package q;
  import p::*;
  localparam int QW = 3;
endpackage
package r;
  localparam logic [3:0] R1 = 4'h9;
  parameter logic [7:0] X = {R1, 4'h0};
endpackage
module sub import p::*; import q::*; import r::*; (output logic [7:0] o);
  assign o = p::X + r::X + QW;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
