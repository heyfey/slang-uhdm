// § genLpSysCallArgName239
// a generate-scope localparam inside an interface and a program
interface bus_if #(parameter int N = 4);
  logic [N-1:0] d;
  if (N > 1) begin : g
    localparam int W = $clog2(N);
    logic [W-1:0] idx;
  end
endinterface
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  bus_if #(.N(N)) b ();
  if (N > 2) begin : gm
    localparam int unsigned K = $clog2(N);
    assign o = r[0] ^ (K > 1);
  end else begin : gn
    assign o = r[0];
  end
endmodule
