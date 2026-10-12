// § inlineAggReturnVarSpan299
function automatic struct packed { logic a; logic b; } [1:0] uf(input logic [3:0] v);
  return v;
endfunction
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = uf(i);
endmodule
