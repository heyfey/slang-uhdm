// § classRetFillUnsized433
class C;
  class D;
    function logic [3:0] f(); return '1; endfunction
  endclass
endclass
module top; C c; initial c = new; endmodule
