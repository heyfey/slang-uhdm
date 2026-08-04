package tp;
  parameter int TL_AW = 32;
  parameter logic [7:0] BW = 8'd6;
  localparam int LP = 5;
endpackage

module m2 #(
  parameter int                   PVal   = tp::TL_AW,        // rhs value
  parameter int                   PValOp = tp::TL_AW - 1,    // rhs operation
  parameter logic [tp::TL_AW-1:0] PQual  = 'h0,              // range bound (known head)
  parameter logic [tp::BW-1:0]    PTyped = 'h0,              // pkg param w/ logic type
  parameter logic [tp::LP-1:0]    PLocP  = 'h0,              // pkg LOCALparam
  parameter logic [tp::TL_AW:0]   PNoOp  = 'h0               // bare bound, no operation
) (
  input clk_i
);
  localparam int LC = tp::TL_AW;
  logic [tp::TL_AW-1:0] sig;
  logic [tp::BW-1:0]    sig2;
endmodule
