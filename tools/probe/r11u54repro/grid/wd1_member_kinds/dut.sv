// r11u54 arm — LAW D re-cut: the elaborated PACKAGE copy re-stamps every
// assignment-pattern element to ITS OWN typespec_member's width.  vd1 varied
// the widths (8/16/64/32) with one wrapper kind per member; this arm crosses
// WIDTH x MEMBER KIND x WRAPPER KIND and puts a `parameter` beside the
// `localparam` so the holder kind is controlled too.
package pk;
  parameter int K = 3;
  typedef struct packed {
    logic [7:0]  a;   // 8   <- bare literal 64 (must NARROW)
    logic [15:0] b;   // 16  <- unsigned'(64)
    logic [63:0] c;   // 64  <- $unsigned(64) (already 64: control)
    int unsigned d;   // 32  <- 32'(64) (already 32: control)
    logic [3:0]  e;   // 4   <- K+1, an OPERATION element (must reduce first)
    byte         f;   // 8   <- bare literal, SIGNED member kind
    logic [2:0]  g;   // 3   <- based literal 4'd5 (narrow from 4)
    logic        h;   // 1   <- bare literal 1
  } m_t;
  localparam m_t L = '{ a: 64, b: unsigned'(64), c: $unsigned(64), d: 32'(64),
                        e: K + 1, f: 7, g: 4'd5, h: 1 };
  parameter  m_t P = '{ a: 64, b: unsigned'(64), c: $unsigned(64), d: 32'(64),
                        e: K + 1, f: 7, g: 4'd5, h: 1 };
  // POSITIONAL (simple) pattern over the same struct.
  localparam m_t S = '{ 64, unsigned'(64), $unsigned(64), 32'(64), K + 1, 7, 4'd5, 1 };
endpackage
// MODULE-SCOPE control: both producers already re-stamp here.  It must not move.
module dut (output logic [63:0] o);
  localparam pk::m_t M = '{ a: 64, b: unsigned'(64), c: $unsigned(64),
                            d: 32'(64), e: pk::K + 1, f: 7, g: 4'd5, h: 1 };
  assign o = pk::L.a | pk::L.b | pk::L.c | pk::L.d | pk::L.e | pk::L.f |
             pk::L.g | pk::L.h |
             pk::P.a | pk::P.e | pk::S.a | pk::S.e |
             M.a | M.e;
endmodule
