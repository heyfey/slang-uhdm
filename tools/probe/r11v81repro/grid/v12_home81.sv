// r11v81 adversarial arm v12 — WHOSE HOME DECIDES: the HOP's or the
// PATTERN's?  A package pattern with a CROSS-package qualified setter, a
// package pattern read into a module localparam by a bare name, and the same
// package params spelled into a MODULE pattern.
package v12a;
  localparam AH = 16'h5;
  localparam AD = 16'd5;
  localparam AU = 5;
endpackage
package v12b;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t12;
  localparam t12 XQ = '{bail: 8'hxA, a: v12a::AU, b: v12a::AH, c: v12a::AD};
endpackage
module v12_home81 (output logic [23:0] o1, output logic [23:0] o2);
  localparam v12b::t12 LREAD = v12b::XQ;
  localparam v12b::t12 MOWN  = '{bail: 8'hxA, a: v12a::AU, b: v12a::AH,
                                 c: v12a::AD};
  assign o1 = LREAD.a ^ LREAD.b ^ LREAD.c;
  assign o2 = MOWN.a ^ MOWN.b ^ MOWN.c;
endmodule
