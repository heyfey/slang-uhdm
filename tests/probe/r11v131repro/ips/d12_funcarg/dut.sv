// § constCtxCallArgInner131v
module top ();
  function automatic int f(logic [7:0] x); return x + 1; endfunction
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam int P = f(A[8 +: 8]);
endmodule
