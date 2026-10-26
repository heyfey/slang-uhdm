// § classRetFillUnsized433
module top #(parameter type T = logic [3:0]) (output [3:0] y);
  function T g();
    return '1;
  endfunction
  assign y = g();
endmodule
