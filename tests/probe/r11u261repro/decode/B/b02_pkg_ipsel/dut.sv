// § shadowedImportParamFold (decode only, ground A: Earlgrey #233633 / #233638, ExprEmit names the folded ts ref after the select where golden names the module)
package rp;
  localparam int OffD = 1;
endpackage
module ctrl import rp::*; (input clk_i, input [1:0] rst_req_i, output logic [0:0] q);
  localparam int Start = 1;
  always_ff @(posedge clk_i) q <= ~rst_req_i[Start +: OffD];
endmodule
module top;
  logic c; logic [1:0] r; logic [0:0] q;
  ctrl u (.clk_i(c), .rst_req_i(r), .q(q));
endmodule
