// v11u61 arm v5 — PASS-59 FACE INTERACTION (package select + import copies)
package v5p;
  typedef struct { byte b8; shortint s16; int i32; } b_t;
  localparam b_t PB = '{b8: 1, s16: 2, i32: 3};
  localparam int SEL = PB.s16;
  typedef struct { byte c8; shortint c16; } c_t;
  localparam c_t PC = '{c8: 4, c16: 5};
endpackage

module v5child;
  import v5p::*;
  localparam int V = PC.c16;
  localparam v5p::c_t LC = '{c8: 6, c16: 7};
endmodule

module v5;
  import v5p::*;
  localparam int U = PB.i32;
  logic [SEL-1:0] w;
  v5child ch();
endmodule
