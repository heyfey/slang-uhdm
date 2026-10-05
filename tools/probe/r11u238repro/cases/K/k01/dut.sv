// § cloneForIncBindsHomeVar238
package p;
  function int unsigned h(string s, int unsigned seed = 0);
    bit [7:0] cb;
    bit [31:0] c;
    c = 32'hffffffff;
    for (int b = 0; b < s.len(); b++) begin
      cb = s[b];
      if (cb == 0) break;
      for (int k = 0; k < 8; k++) begin
        c <<= 1;
        if (cb[k]) c[0] = 1;
      end
    end
    h = c + seed;
  endfunction
endpackage
package q;
  import p::*;
  function int unsigned qh(string s);
    return h(s);
  endfunction
endpackage
module top;
  import q::*;
  int unsigned r;
  initial r = qh("ab");
endmodule
