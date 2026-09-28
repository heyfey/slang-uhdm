// § ndaSysCallNetTs212 — r11u217 n06: net declarations with signing casts and system calls in a GENERATE scope (for and if) of a module, and a net declaration with a cast whose operand is a concatenation
module dut(input logic [3:0] x, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    wire signed [3:0] s = signed'(x);
    wire [1:0] u = $unsigned(x[k*2 +: 2]);
    assign o[k*2 +: 2] = u ^ s[1:0];
  end
  if (1) begin : h
    wire [3:0] c = unsigned'({x[1:0], x[3:2]});
    assign o[7:4] = c;
  end
endmodule
