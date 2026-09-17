// r11u61 h4 — THE SHAPE FENCES at the ELABORATED UNPACKED-struct face.
// One module, one parameter per shape, only the SHAPE varying.
module h4 (input logic clk);
  typedef struct packed { logic [3:0] x; logic [7:0] y; } inner_t;
  typedef struct { byte b8; inner_t n; int i32; } n4_t;   // PATTERN-VALUED elem
  typedef struct { byte b8; real r; int i32; } r4_t;      // REAL member
  typedef struct { byte b8; time t; int i32; } t4_t;      // TIME member
  typedef struct { byte b8; string s; int i32; } s4_t;    // STRING member
  typedef struct { byte b8; int a[2]; int i32; } a4_t;    // UNPACKED-ARRAY member
  typedef struct { byte b8; logic [95:0] w96; int i32; } w4_t; // >64b member
  localparam n4_t NEST = '{b8: 1, n: '{x: 4'h3, y: 8'hA5}, i32: 7};
  localparam r4_t REAL4 = '{b8: 1, r: 2.5, i32: 7};
  localparam t4_t TIME4 = '{b8: 1, t: 64'd5, i32: 7};
  localparam s4_t STR4 = '{b8: 1, s: "ab", i32: 7};
  localparam a4_t ARR4 = '{b8: 1, a: '{3, 4}, i32: 7};
  localparam w4_t WIDE4 = '{b8: 1, w96: 96'h1, i32: 7};
  wire z = clk ^ NEST.b8[0] ^ TIME4.b8[0] ^ ARR4.b8[0] ^ WIDE4.b8[0]
                ^ REAL4.b8[0] ^ STR4.b8[0];
endmodule
