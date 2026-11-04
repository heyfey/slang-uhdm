// § classRetFillUnsized433
class C;
  function logic [3:0] f(input bit a);
    if (a) return '1;
    else begin
      return '0;
    end
  endfunction
endclass
module top; C c; initial c = new; endmodule
