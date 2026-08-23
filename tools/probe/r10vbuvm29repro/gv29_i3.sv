// r10vbuvm29 arm I3 (VERIFIER) — the SAME cast-over-stream carried by 3
// instance(s) of one module, to check the ELABORATED view mints exactly one
// cast per instance and no more.
package vi29;
  typedef enum bit [7:0] { I0 = 8'h1 } ie;
endpackage
module vi29m;
  import vi29::*;
  ie e1; bit __a[];
  always_comb e1 = ie'({ << bit { __a }});
endmodule
module vi29top;
  vi29m u1();
  vi29m u2();
  vi29m u3();
endmodule
