// § inlineAggReturnVarSpan299
module dut(input logic [1:0] i, output logic [1:0] o);
  function automatic struct packed { logic a; logic b; } f(input logic [1:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
