// § pkgAggTfArgCloneFollows180 (verifier: single-line typedef, the writer formal on the SAME line as another use)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t; function automatic logic [7:0] f(input s_t v); return v; endfunction
  localparam s_t K = '{a: 7, b: 8};
endpackage
module top import p::*; (output logic [7:0] y);
  assign y = f(K);
endmodule
