// r10earl105 g1 — ENCODINGS of the substituted constant, TOP-module loop-gen
// scope, plain operand.  Golden copies the param_assign Rhs verbatim; the
// question is whether we mint a UINT decimal instead.
module g1_enc105 (output logic [7:0] z);
  localparam int            PDEC  = 5;              // INT / decimal
  localparam logic [7:0]    PBIN  = 8'b1010_0101;   // BIN
  localparam logic [7:0]    PHEX  = 8'hA5;          // HEX
  localparam logic [31:0]   PREPL = {32{1'b1}};     // BIN from a replication fold
  localparam bit   [7:0]    PBIT  = 8'd7;           // bit vector
  localparam logic signed [7:0] PSGN = -8'sd3;      // signed

  for (genvar i = 0; i < 2; i++) begin : gen_l
    logic [63:0] w_dec, w_bin, w_hex, w_repl, w_bit, w_sgn;
    assign w_dec  = $bits(w_dec)'({PDEC,  1'b1});
    assign w_bin  = $bits(w_bin)'({PBIN,  1'b1});
    assign w_hex  = $bits(w_hex)'({PHEX,  1'b1});
    assign w_repl = $bits(w_repl)'({PREPL, 1'b1});
    assign w_bit  = $bits(w_bit)'({PBIT,  1'b1});
    assign w_sgn  = $bits(w_sgn)'({PSGN,  1'b1});
  end
  assign z = 8'h0;
endmodule
