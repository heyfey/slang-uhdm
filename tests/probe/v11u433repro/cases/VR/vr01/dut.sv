// § classRetFillUnsized433
class C;
  function bit [7:0] f(); return '1; endfunction
  function int g(); return '0; endfunction
endclass
module top; C c; initial c = new; endmodule
