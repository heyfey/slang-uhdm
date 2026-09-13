// A USER FUNCTION CALL inside the operation Rhs: does reduceExpr still
// rebuild, or does invalidValue leave the Rhs (and its bindings) alone?
module top(input logic [31:0] a, output logic [31:0] o);
  function automatic logic [31:0] f(input logic [31:0] x); return x + 1; endfunction
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = f(src) | 32'd1;
  end
  assign o = mv;
endmodule
