// § constCtxCallArgInner131v
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  parameter int W = 1;
  localparam logic [7:0] P = (W > 0) ? A[8 +: 8] : 8'h0;
endmodule
