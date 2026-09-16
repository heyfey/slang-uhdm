// r11u49 arm a5 — an UNPACKED struct localparam WIDER than 64 bits, package
// scope, read scoped.  The landed WIDTH RULE (>64b package struct keeps the
// tagged tree in the elab view too) is packed-only today.
package p;
  typedef struct { int unsigned A; int unsigned B; int unsigned C; } n96_t;   // 96b
  typedef struct { int unsigned A; } n32_t;                                   // 32b
  localparam n96_t W96 = '{A:1, B:2, C:3};
  localparam n32_t W32 = '{A:4};
endpackage
module a5 (output logic [31:0] o);
  assign o = p::W96.B + p::W32.A;
endmodule
