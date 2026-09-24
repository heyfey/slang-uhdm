// § paramFoldParenSpan131
module top #(parameter A = 3) ();
  localparam B = (A);
  localparam C = ((A+1));
  logic [B:0] x;
endmodule
