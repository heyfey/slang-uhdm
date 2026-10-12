// § parenCastReadsCastSyntax288 — constant slots: parameter initializers and defaults, part-select bounds, replication counts, dimension bounds
module m #(parameter int N = (int'(3'd4)), parameter logic [7:0] D = (byte'(9)))(input logic [15:0] x, output logic [15:0] o, p, q);
  localparam int L = (int'(N)) + 1;
  localparam logic [(int'(N))-1:0] K = '1;
  logic [(int'(L))-1:0] r;
  assign o = x[(int'(N))-1:0];
  assign p = {(int'(2)){x[3:0]}};
  assign q = x[(int'(N)) +: 4] + K + D;
  assign r = '0;
endmodule
module top(input logic [15:0] x, output logic [15:0] o, p, q);
  m #(.N((int'(5)))) u(.*);
endmodule
