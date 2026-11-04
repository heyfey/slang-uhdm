// § caConstVarFoldNeedsReducibleInit301
package p;
  int w = 6;
endpackage
module child (output int o);
  assign o = p::w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
