// § genLpSysCallArgName239
// two instances of the module with different N, the localparam read by a declaration
module leaf #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  if (N != 1) begin : gen_normal_case
    localparam int unsigned NumLevels = $clog2(N);
    logic [NumLevels-1:0] t;
    assign t = r[NumLevels-1:0];
    assign o = ^t;
  end else begin : gen_deg
    assign o = r[0];
  end
endmodule
module top (input logic [7:0] r, output logic [1:0] o);
  leaf #(.N(4)) u0 (.r(r[3:0]), .o(o[0]));
  leaf #(.N(8)) u1 (.r(r), .o(o[1]));
endmodule
