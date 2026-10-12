// § parenCastReadsCastSyntax288 — parenthesized casts to a package enum, a parameter size, a parenthesized parameter size and signedness in a process
package pk; typedef enum logic [1:0] {A, B, C} e_t; endpackage
module top #(parameter int W = 3)(input logic [7:0] x, output logic [7:0] o, output logic [1:0] e);
  logic [7:0] y;
  always_comb begin
    e = (pk::e_t'(x[1:0]));
    o = (W'(x)) + ((W)'(x));
    y = (signed'(x)) >>> 1;
    y = y + (unsigned'(x));
  end
endmodule
