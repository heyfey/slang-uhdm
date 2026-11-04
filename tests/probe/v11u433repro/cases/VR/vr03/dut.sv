// § classRetFillUnsized433
class C #(int W = 4);
  function logic [W-1:0] f(); return '1; endfunction
endclass
module top; C #(8) c; initial c = new; endmodule
