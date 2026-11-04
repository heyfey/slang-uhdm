// § inlineAggReturnVarSpan299
module dut(input logic [11:0] i, output logic [11:0] o);
  function automatic union packed { logic [1:0] a; logic [1:0] b; } [2:0][1:0] f(input logic [11:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
