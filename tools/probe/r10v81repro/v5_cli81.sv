// r10v81 arm v5 — THE COMMAND-LINE (-G / -P) OVERRIDE TRAP.  slang binds a -G
// override exactly like an instantiation override, so `isOverriddenParam` says
// TRUE (ParamEmit.cpp's `cliOverridden` exists precisely because Surelog's
// cmdline path is a DIFFERENT one).  The shipped law does NOT consult
// `cliOverridden`.  MEASUREMENT ONLY.
module leafv5 (input logic ib, output logic o);
  assign o = ib;
endmodule
module topv5 #(parameter int unsigned N = 1)
              (input logic [15:0] w, output logic o);
  leafv5 uCli (.ib(w[N]), .o(o));
endmodule
