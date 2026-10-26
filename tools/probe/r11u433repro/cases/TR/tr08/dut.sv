// § classRetFillUnsized433
module top;
  class C;
    function logic [3:0] g();
      return '1;
    endfunction
  endclass
  C c = new;
endmodule
