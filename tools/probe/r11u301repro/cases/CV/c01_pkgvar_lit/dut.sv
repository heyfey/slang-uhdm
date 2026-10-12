// § caConstVarFoldNeedsReducibleInit301
package p;
  int w = 6;
endpackage
module child (output int o);
  import p::*;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
