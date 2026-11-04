// § cloneTfItemLocalOwnVar253 (a paren-less function written in a macro body)
`define MKF(N) function automatic int N; int x; x = 7; return x; endfunction
package p;
  `MKF(f1)
  `MKF(f2)
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
