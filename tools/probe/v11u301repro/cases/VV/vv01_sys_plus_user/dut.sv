// § constVarNestedCallFolds301v
module child (output int o);
  function automatic int mk(); return 2; endfunction
  int w = $clog2(8) + mk();
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
