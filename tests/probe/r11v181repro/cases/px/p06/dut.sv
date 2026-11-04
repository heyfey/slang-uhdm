// § bitSelParenIdxSpan181 (v11u181 break: parenthesized index nonblocking rhs in always_ff, ternary select, index inside an index)
module top(input logic clk, input logic [7:0] a, input logic [2:0] i, input logic [2:0] b [0:3], output logic y, z);
  always_ff @(posedge clk) begin
    y <= a[(b[(i[1:0])])];
    z <= i[0] ? a[(i)] : a[(3'd2)];
  end
endmodule
