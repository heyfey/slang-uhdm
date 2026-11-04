// § inlineAggReturnVarSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic union packed { logic [1:0] a; logic [1:0] b; } [1:0] f(input logic [3:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
