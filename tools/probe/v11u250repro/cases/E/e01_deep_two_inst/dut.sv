// § modParamKwTdCopy250
// a parameter typed by a package keyword typedef in a module instantiated twice at depth 3 and 2, overridden at one
package p;
  typedef int unsigned ui_t;
  typedef bit signed sb_t;
endpackage
module leaf #(parameter p::ui_t W = 4, parameter p::sb_t S = 1'b1) (output logic [7:0] o);
  import p::*;
  localparam ui_t L = W + 1;
  assign o = {L[3:0], 3'b0, S};
endmodule
module mid(output logic [7:0] o);
  leaf #(.W(6)) l(.o(o));
endmodule
module top(output logic [7:0] o1, o2);
  mid m(.o(o1));
  leaf l2(.o(o2));
endmodule
