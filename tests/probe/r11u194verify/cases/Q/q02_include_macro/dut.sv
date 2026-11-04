// § macroPathTokSpans183 § macroPathTokOneBuffer186: dotted paths inside macros defined in an included file, one with a macro-argument index (two buffers) and one path-to-path copy
`include "defs.svh"
interface fif;
  logic [3:0] flags;
  logic [7:0] val;
endinterface
module m (fif a, fif b);
  `TIE_HI(a, 2)
  `COPY(b, a)
endmodule
module top;
  fif x (), y ();
  m u (.a(x), .b(y));
endmodule
