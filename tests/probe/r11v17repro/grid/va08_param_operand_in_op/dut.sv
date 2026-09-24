// A module PARAMETER as an operand of the operation Rhs (the brief's
// "a module PARAMETER in the Rhs re-opens the cont-assign gate").
module top(input logic [31:0] a, output logic [31:0] o);
  parameter logic [31:0] P = 32'd7;
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = src | P;
  end
  assign o = mv;
endmodule
