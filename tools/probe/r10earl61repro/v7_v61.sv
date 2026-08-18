// r10v61 VERIFIER -- measured: pristine and patched BYTE-IDENTICAL on this arm.
// r10v61 — the LATENT >64-bit MASK cell: NumUtils::getMask SATURATES at 64 bits
// (golden writes UINT:18446744073709551615 for ANY member wider than 64), while
// the landed `default:` half's SVInt::setAllOnes does not.  Reached through the
// UNFENCED default half, which pristine already runs.
package py61;
  typedef struct packed { logic [127:0] m128; logic [64:0] m65; logic [7:0] m8; } w61_t;
  typedef struct packed { logic [127:0] m128; logic [7:0] m8; } x61_t;
endpackage
module v7_v61 (input logic clk, output py61::w61_t o1, output py61::x61_t o2,
               output py61::x61_t o3);
  import py61::*;
  assign o1 = '{ default : '1 };
  assign o2 = '{ m8 : 8'hFF, default : '1 };
  assign o3 = '{ default : '0 };
endmodule
