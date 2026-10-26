// § classRetFillUnsized433
class C;
  function logic [3:0] f();
    logic [3:0] r;
    r = '1;
    return '0;
  endfunction
  function int g(); return f(); endfunction
endclass
module top; C c; initial c = new; endmodule
