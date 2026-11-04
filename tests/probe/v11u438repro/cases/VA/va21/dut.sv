// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  function automatic logic g(input logic [15:0] v); return v[0]; endfunction
  assign y = g(b['hF:'h0]);
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
