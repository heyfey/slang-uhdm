// § pkgAggTfArgCloneFollows180 § modAggTfArgCloneFollows180 (r11u190: a package function and a MODULE function take the same imported struct typedef as a formal; copies in both scopes)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic logic [3:0] pf(input s_t x); return x.a; endfunction
  localparam s_t PP = '{a:4'h1, b:4'h2};
endpackage
module top import p::*; (output logic [3:0] o1, o2);
  function automatic logic [3:0] mf(input s_t y); return y.b; endfunction
  localparam s_t MP = '{a:4'h5, b:4'h6};
  assign o1 = pf(PP);
  assign o2 = mf(MP);
endmodule
