// § caPlainLhsUnsizedClone438 (control: a call over constants only)
module sub(output [15:0] y);
  function automatic logic [15:0] f(input int k); return k + 1; endfunction
  assign y = f('h3);
endmodule
module top(output [15:0] y);
  sub u(.y(y));
endmodule
