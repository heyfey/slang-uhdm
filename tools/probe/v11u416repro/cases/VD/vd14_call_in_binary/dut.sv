// § defGenConnSelAtIndex416
module sub(input logic a, output logic o);
  assign o = a;
endmodule
module top(input logic [3:0] x, y, output logic [3:0] z);
  function automatic logic f(logic v); return v; endfunction
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a(y[i] & f(x[i])), .o(z[i]));
  end
endmodule
