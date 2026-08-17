interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  function automatic logic [AW-1:0] f(input logic [AW-1:0] x);
    return x + 1;
  endfunction
  logic [AW-1:0] y;
  assign y = f(a);
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
