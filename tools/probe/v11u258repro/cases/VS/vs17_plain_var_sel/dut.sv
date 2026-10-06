// § lvStreamBaseKeepsActual258 (plain variables with bit, part and indexed part selects as stream targets in a module and a function)
module m; logic [7:0] v, w; logic [3:0] x; logic [7:0] o;
  function automatic logic [7:0] f(logic [3:0] a); logic [7:0] t; {>>{t[3:0]}} = a; return t; endfunction
  always_comb begin {>>{v[3:0], w[2+:2], v[7]}} = {x, 2'b01, 1'b0}; o = f(x); end
endmodule
module top; m u(); endmodule
