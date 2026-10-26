// § defOnlyAliasVarNoNetType440
module m (input clk);
  typedef logic [3:0] t;
  task tk; t loc; loc = 0; endtask
  function automatic t f(t a); t r; r = a; return r; endfunction
  t z;
endmodule
module top; endmodule
