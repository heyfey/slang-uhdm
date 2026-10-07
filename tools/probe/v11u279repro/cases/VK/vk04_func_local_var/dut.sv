// § inlineStructPortVarKwSpan279
module dut(input logic [2:0] i, output logic [2:0] o);
  function automatic logic [2:0] f(input logic [2:0] x);
    var struct packed { logic [1:0] a; logic b; } t;
    t = x;
    return t;
  endfunction
  assign o = f(i);
endmodule
