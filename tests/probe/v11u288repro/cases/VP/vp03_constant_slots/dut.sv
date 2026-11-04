// § parenCastReadsCastSyntax288 — a parenthesized cast as a select index, a part-select bound, an indexed width, a replication count and a dimension bound
module top #(parameter int W = 4)(input logic [15:0] a, input logic [3:0] i, output logic [15:0] o);
  logic [(int'(W)) - 1:0] d;
  assign o[0] = a[(int'(i))];
  assign o[4:1] = a[(int'(i)) +: 4];
  assign o[8:5] = a[(int'(7)):(int'(4))];
  assign o[12:9] = {(int'(2)){a[1:0]}};
  assign d = a[(byte'(W)) - 1:0];
  assign o[15:13] = a[i +: (int'(3))];
endmodule
