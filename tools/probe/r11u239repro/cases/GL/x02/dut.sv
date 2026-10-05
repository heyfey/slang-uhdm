// § genLpSysCallArgName239
// two modules with the same block name, a package parameter argument, a parameter with no type
package pk; parameter int Q = 8; endpackage
module a #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  if (N > 1) begin : g
    localparam L = $clog2(N);
    localparam int K = $clog2(pk::Q);
    assign o = r[0] ^ (L > K);
  end
endmodule
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic [1:0] o);
  if (N > 1) begin : g
    localparam int L = $clog2(N);
    assign o[0] = r[0] ^ (L > 1);
  end
  a #(.N(N)) u (.r(r), .o(o[1]));
endmodule
