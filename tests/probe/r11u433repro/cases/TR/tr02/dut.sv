// § classRetFillUnsized433
class C #(type T = logic [3:0]);
  function T g();
    return '0;
  endfunction
endclass
module top; endmodule
