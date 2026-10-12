// § constVarNestedCallFolds301v
module child (output int o);
  function automatic int mk(); return 4; endfunction
  int w = -mk();
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
