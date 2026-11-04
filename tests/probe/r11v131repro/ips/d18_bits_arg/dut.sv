// § constCtxCallArgInner131v
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam int P = $bits(A[8 +: 8]);
endmodule
