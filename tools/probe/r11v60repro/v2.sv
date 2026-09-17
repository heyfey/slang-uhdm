// v2 — PACKED struct carrying a `time` member, package-selected, at the
// import-copy face.  The landed time fence (§ unpNonIntegralMemberDeclined49v)
// is applied by r11u60 ONLY when the struct is UNPACKED; a packed struct may
// hold `time` too.  Beside it the unpacked twin (the fenced control) and a
// plain packed control.
package p2t;
  typedef struct packed { time t; logic [31:0] a; } tp_t;
  typedef struct        { time t; int unsigned a; } tu_t;
  typedef struct packed { logic [31:0] q; logic [31:0] a; } cp_t;
  localparam tp_t TPK = '{t: 64'd1, a: 32'd4};
  localparam tu_t TUN = '{t: 64'd1, a: 4};
  localparam cp_t CPK = '{q: 32'd7, a: 32'd4};
  function automatic int unsigned pf2();      // never called: the RFDEAD face
    return TPK.a + TUN.a + CPK.a;
  endfunction
endpackage

module v2q import p2t::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module v2top(input logic clk);
  logic [7:0] dd;
  v2q u_q (.clk(clk), .d(dd));
endmodule
