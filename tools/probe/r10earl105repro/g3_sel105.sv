// r10earl105 g3 — the SELECT / INDEX / COUNT positions, with a NON-decimal
// parameter, so "golden COPIES the param_assign Rhs" and "golden MINTS a
// use-site UINT" are distinguishable there too.  TOP module, loop generate.
module g3_sel105 (
  input  logic [7:0]  sig,
  input  logic [31:0] vec,
  output logic [63:0] z
);
  localparam logic [7:0] PB = 8'b0000_0101;   // BIN, value 5
  localparam logic [7:0] PH = 8'h05;          // HEX, value 5
  localparam bit   [7:0] PT = 8'b0000_0011;   // BIN bit-vector, value 3

  for (genvar i = 0; i < 2; i++) begin : gen_l
    logic [63:0] m1, m2, m3, m4, m5, m6, m7, m8;
    // m1 — a REPLICATION COUNT
    assign m1 = {PB{1'b1}} ^ sig;
    // m2 — a BIT-SELECT INDEX
    assign m2 = vec[PB];
    // m3 — an INDEXED-PART-SELECT base
    assign m3 = vec[PB +: 2];
    // m4 — a PART-SELECT bound written as an operation
    assign m4 = vec[PB+1 : PB];
    // m5 — a bit-select index written as an OPERATION
    assign m5 = vec[PB-1];
    // m6 — a SYSTEM-CALL argument
    assign m6 = $clog2(PH) ^ sig;
    // m7 — a TERNARY condition
    assign m7 = PT ? sig : 8'b0;
    // m8 — a HEX parameter as a plain operand (the control)
    assign m8 = PH ^ sig;
  end
  assign z = 64'b0;
endmodule
