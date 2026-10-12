// § constVarNestedCallFolds301v
module child (output int o);
  function automatic int mk(); return 9; endfunction
  int w = $clog2(mk());
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
