// § newArrayBitSelIdxStripped220 § newArrayCallArgStripped220 — new[] sized by a member's bit select, a bit select of a queue, and a call on a bit select
package p;
typedef struct { int len [3]; } desc_t;
class c;
  desc_t dsc;
  int qq [$];
  function int twice(int a); return 2 * a; endfunction
  function void f(int k);
    byte b1 []; byte b2 []; byte b3 [];
    b1 = new[dsc.len[k]];
    b2 = new[qq[k]];
    b3 = new[twice(qq[k])];
  endfunction
endclass
endpackage
module top; endmodule
