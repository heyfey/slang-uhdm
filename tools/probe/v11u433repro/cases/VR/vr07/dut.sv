// § classRetFillUnsized433
class C;
  function logic [3:0] f(); return '1; endfunction
endclass
module top;
  function logic [3:0] h(); return '1; endfunction
  C c; logic [3:0] q; initial begin c = new; q = h(); end
endmodule
