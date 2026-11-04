// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  function automatic int f(int v); return v + 1; endfunction
  if (1) begin: g
    assign y = f($bits(x));
  end
endmodule
