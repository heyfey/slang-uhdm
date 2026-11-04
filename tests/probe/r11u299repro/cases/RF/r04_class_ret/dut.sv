// § inlineAggReturnVarSpan299
class c;
  function struct packed { logic a; logic b; } [1:0] f(input logic [3:0] v);
    return v;
  endfunction
endclass
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
