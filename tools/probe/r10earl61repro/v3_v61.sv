// r10v61 ADVERSARIAL GRID 3 — law B: member WIDTHS across the 64-bit boundary,
// signedness, enum/array/nested-struct member types, and 'z.
package pw61;
  typedef struct packed {
    logic [62:0] w63;
    logic        w1;
  } s64_t;                       // exactly 64 total, members 63 + 1
  typedef struct packed {
    logic [63:0] m64;
    logic [64:0] m65;
  } s129_t;                      // members STRADDLING the 64-bit mask boundary
  typedef struct packed {
    logic [127:0] m128;
    logic [7:0]   m8;
  } s136_t;
  typedef enum logic [2:0] { Z0 = 3'd0, Z1 = 3'd1 } ez_t;
  typedef struct packed {
    ez_t          e;
    logic signed [7:0] si;
    logic [1:0][3:0]   pa;
  } smix_t;
  typedef struct packed { logic [3:0] a; logic [1:0] b; } in61_t;
  typedef struct packed { logic [2:0] p; in61_t q; logic [4:0] r; } out61_t;
endpackage

module v3_v61 (input logic clk,
               output pw61::s64_t  o1, output pw61::s64_t  o2,
               output pw61::s129_t o3, output pw61::s129_t o4,
               output pw61::s136_t o5, output pw61::s136_t o6,
               output pw61::smix_t o7, output pw61::smix_t o8,
               output pw61::out61_t o9, output pw61::out61_t o10);
  import pw61::*;

  // C1/C2: 63+1 bit members, all-ones and all-zeros
  assign o1 = '{ w63 : '1, w1 : '1 };
  assign o2 = '{ w63 : '0, w1 : 'z };

  // C3/C4: 64-bit and 65-bit members -- THE MASK BOUNDARY
  assign o3 = '{ m64 : '1, m65 : '1 };
  assign o4 = '{ m64 : '0, m65 : 'x };

  // C5/C6: a 128-bit member
  assign o5 = '{ m128 : '1, m8 : '1 };
  assign o6 = '{ m128 : '0, m8 : 'x };

  // C7/C8: enum-typed, SIGNED, and packed-array members
  assign o7 = '{ e : Z0, si : '1, pa : '1 };
  assign o8 = '{ e : Z1, si : '0, pa : 'x };

  // C9: nested struct member alongside unsized values on both sides
  assign o9  = '{ p : '1, q : '{ a : '1, b : '0 }, r : '1 };
  // C10: default fill covering the WIDE members (the landed half, unchanged)
  assign o10 = '{ p : '1, default : '1 };
endmodule
