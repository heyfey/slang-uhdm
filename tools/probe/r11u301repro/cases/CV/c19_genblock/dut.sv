// § caConstVarFoldNeedsReducibleInit301
package p;
  function int mk(); return 6; endfunction
  int w = mk();
endpackage
module child (output int o);
  import p::*;
  if (1) begin : g
    assign o = w;
  end
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
