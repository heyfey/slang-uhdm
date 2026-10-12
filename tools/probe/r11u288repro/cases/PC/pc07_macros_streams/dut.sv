// § parenCastReadsCastSyntax288 — macro-born casts (the parentheses in the macro body), a string cast and a cast over a macro
`define CI(v) (int'(v))
`define CB(v) ((byte'(v)))
module top(input logic [7:0] x, output logic [31:0] y, z, w);
  typedef logic [31:0] w32_t;
  string s;
  always_comb begin
    y = `CI(x) + 1;
    z = `CB(x) + `CI(x[3:0]);
    s = (string'("ab"));
    w = (w32_t'(`CI(x)));
  end
endmodule
