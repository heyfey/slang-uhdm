// § constVarNestedCallFolds301v
module child #(parameter bit P = 1) (output int o);
  function automatic int mk(); return 4; endfunction
  int w = P ? mk() : 3;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
