// g8 — THE TYPE-KEY face at the import-copy site, ALONE.  Recorded because it
// is NOT MEASURABLE against golden: Surelog v1.87 raises
//   [ERR:UH0713] Unmatched member during pattern assignment "b"
// the moment a type-key pattern parameter is MATERIALIZED into an importing
// module (r11u49's b3 reads the same parameter `p::UTYP.A` from a module that
// does NOT import, and compiles clean).  An arm whose compile fails teaches
// error recovery, not golden — so the type-key fence stays, inherited from the
// package-listing verdict, and is never widened here.
package p8;
  typedef struct { int a; int b; } ip_t;
  localparam ip_t FTYP = '{int: 5};
  function automatic int f8(); return FTYP.a; endfunction
endpackage

module g8q import p8::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module g8top(input logic clk);
  logic [7:0] dd;
  g8q u_q (.clk(clk), .d(dd));
endmodule
