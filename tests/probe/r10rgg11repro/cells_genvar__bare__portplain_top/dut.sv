// r10rgg11 cell genvar__bare__portplain — THE ARM THAT MUST NOT MOVE.
// A GENVAR read as a bare port actual keeps § genvarConnFold's 64-bit UINT
// fold: genvars never reach the two genLpPaBySym11 fill sites (they have no
// param_assign), so the law cannot see them.
module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    sink #(8) u (.i_value(gi));
  end
endmodule
