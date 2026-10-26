// § classRetFillUnsized433
class C;
  function logic [3:0] f(); return 'x; endfunction
  function logic [3:0] g(); return 'z; endfunction
endclass
module top; C c; initial c = new; endmodule
