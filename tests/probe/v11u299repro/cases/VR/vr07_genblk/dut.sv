// § inlineAggReturnVarSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    function automatic struct packed { logic a; logic b; } [1:0] f(input logic [3:0] v);
      return v;
    endfunction
    assign o = f(i);
  end
endmodule
