// § constVarNestedCallFolds301v
package p;
  function int mk(); return 6; endfunction
  int w = mk() + 1;
endpackage
module child (output int o);
  import p::*;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
