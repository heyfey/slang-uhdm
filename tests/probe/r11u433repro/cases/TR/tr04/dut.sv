// § classRetFillUnsized433
class C #(type T = logic [3:0]);
  function logic [3:0] g();
    return '1;
  endfunction
endclass
module top; endmodule
