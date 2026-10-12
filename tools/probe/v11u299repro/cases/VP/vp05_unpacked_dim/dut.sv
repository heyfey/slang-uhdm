// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v [2]);
    return v[0];
  endfunction
  logic [3:0] w [2];
  assign w[0] = i; assign w[1] = ~i;
  assign o = f(w);
endmodule
