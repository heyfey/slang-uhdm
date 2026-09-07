// r10v188repro/arms/v188_b_lits.sv — ADVERSARIAL LITERAL SPELLINGS.
// A source-spelled constant MUST STAY source-spelled: hex case, octal, binary,
// leading zeros, digit separators, unsized based, SIGNED tick, and the shapes
// the law must ABSTAIN on (`%`, unary minus, a 64-wide shift, a shift past the
// left operand's width).
package v188b_pkg;
  typedef enum {
    B_HEXU = 8'hFF + 1,
    B_HEXL = 8'hff + 2,
    B_HEXM = 8'hFf + 3,
    B_DEC  = 8'd10 + 4,
    B_BIN  = 4'b1010 + 5,
    B_OCT  = 8'o17 + 6,
    B_LEAD = 007 + 9,
    B_USEP = 1_000 + 1,
    B_UNS  = 'h10 + 2,
    B_UNSD = 'd5 + 3,
    B_UNSB = 'b101 + 4,
    B_SGN  = 8'sh7F + 5,
    B_SGND = 'sd5 + 6,
    B_BIG  = 64'd3 << 4,
    B_SHRZ = 8'hFF >> 9,
    B_SH30 = 1 << 30,
    B_MOD  = 17 % 5,
    B_NEG  = -1 + 20
  } v188b_e;
endpackage
