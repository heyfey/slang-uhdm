// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  function automatic int f(int a); return a + 1; endfunction
  if (W > 1) begin : g
    assign y = f($bits(x));
  end
endmodule
