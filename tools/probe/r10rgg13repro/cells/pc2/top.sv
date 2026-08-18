// r10rgg13 MUST-NOT-MOVE — gate clause (1), the `uhdm2rtlil/func_upto` fence in
// miniature: a SINGLE-packed-dimension localparam whose call still survives.
// Surelog compiles it with Reduce::Yes, so golden's actuals come from the VALUE
// arm and wear the FORMAL's typespec — which is what the base already emits.
module evil;
  parameter HI = 3;
  parameter LO = 0;
  parameter SPAN = 1;
  parameter [HI:LO] A_VAL = 4'b0110;
  parameter [HI:LO] B_VAL = 4'b1100;
  localparam [HI:LO] A_CONST = A_VAL;
  localparam [HI:LO] B_CONST = B_VAL;
  localparam [HI:LO] C_CONST = F(A_CONST, B_CONST);
  function automatic [HI:LO] F(input [HI:LO] D, input [HI:LO] E);
    reg [31:0] i;
    F = 0;
    for (i = LO; i + SPAN < HI; i = i + SPAN)
      if (SPAN == 1) F[i] = D[i] && E[i];
      else           F[i+:SPAN] = D[i+:SPAN] && E[i+:SPAN];
  endfunction
endmodule

module top;
  evil u_e ();
endmodule
