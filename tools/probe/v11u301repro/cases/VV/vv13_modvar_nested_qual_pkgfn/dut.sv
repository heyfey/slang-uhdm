// § constVarNestedCallFolds301v
package p;
  function int mk(); return 6; endfunction
endpackage
module child (output int o);
  int w = p::mk() * 2;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
