// § constVarNestedCallFolds301v
module child (output int o);
  function automatic int mk(int a); return a * 3; endfunction
  int w = mk(1) + mk(2);
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
