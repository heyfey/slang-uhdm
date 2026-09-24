// r10earl46 VERIFIER probe 2 — pin the DIGITS rule.
// § genLpFoldSignedIntReadsBitsSigned46 says the digits are the SIGNED reading
// of the bits whenever the fold is INT-encoded.  BIGMUL refutes that.  These
// four rows separate "bits have the MSB set" from "the value was NEGATIVE
// before it was truncated to the declared width".
module v46v_digits;
  localparam int ARR [5] = '{0, 36, 3, 105, 210};
  for (genvar x = 0; x < 5; x++) begin : gen_x
    // MSB set, value POSITIVE before conversion
    localparam int unsigned D_POSBIG = 32'hC0000000 * 1;
    // SAME BITS, value NEGATIVE before conversion
    localparam int unsigned D_NEGBIG = 0 - 32'h40000000;
    // small negative before conversion, unsigned declared type
    localparam int unsigned D_NEGSML = 0 - 105;
    // the int_types shape: unary minus of a literal, unsigned declared type
    localparam int unsigned D_NEGONE = -1;
    // signed declared type, negative
    localparam int          D_SNEG   = 0 - ARR[x];
    if (x >= 0) begin : gen_use
      wire [63:0] d0 = D_POSBIG + D_NEGBIG + D_NEGSML + D_NEGONE + D_SNEG;
    end
  end
endmodule
