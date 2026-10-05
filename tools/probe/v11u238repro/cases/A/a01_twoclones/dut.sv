// § cloneForIncBindsHomeVar238
// one home function cloned into two importing packages, a re-export chain, loop var in constant slots
package p;
  function automatic int h(logic [31:0] s);
    int c = 0;
    for (int b = 0; b < 4; b++) begin
      c += s[b*8 +: 8];
      c += s[(b*8)+7 -: 2];
      c ^= {b[1:0], b[1:0]};
    end
    return c;
  endfunction
endpackage
package q;
  import p::*;
  export p::*;
  function automatic int qh(logic [31:0] s); return h(s); endfunction
endpackage
package r;
  import p::*;
  function automatic int rh(logic [31:0] s); return h(s) + 1; endfunction
endpackage
package z;
  import q::*;
  function automatic int zh(logic [31:0] s); return qh(s) + h(s); endfunction
endpackage
module top(input logic [31:0] a, output int o1, output int o2, output int o3);
  assign o1 = q::qh(a);
  assign o2 = r::rh(a);
  assign o3 = z::zh(a);
endmodule
