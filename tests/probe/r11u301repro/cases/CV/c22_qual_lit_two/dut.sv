// § caConstVarFoldNeedsReducibleInit301
package p;
  int w = 6;
  int v = 7;
endpackage
module child (output int o, q);
  assign o = p::w;
  assign q = p::v;
endmodule
module dut (output int o, q);
  child u (.o(o), .q(q));
endmodule
