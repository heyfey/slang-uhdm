// § constCtxCallArgInner131v
module top (output logic [31:0] o);
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam int P = $countones(A[8 +: 8]);
  assign o = P;
endmodule
