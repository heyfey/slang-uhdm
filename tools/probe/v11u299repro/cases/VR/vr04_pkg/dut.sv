// § inlineAggReturnVarSpan299
package pk;
  function automatic struct packed { logic a; logic b; } [1:0] f(input logic [3:0] v);
    return v;
  endfunction
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = pk::f(i);
endmodule
