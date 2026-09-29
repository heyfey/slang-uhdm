// § importCloneSharesHomeReturn218 — out-of-body methods returning an enum, a logic vector and a typedef'd queue, a static one, imported by two packages and by $unit
package p1;
  typedef enum logic [1:0] {K0, K1, K2} k_e;
  typedef int iq_t [$];
  class c;
    extern function k_e pick(int i);
    extern function logic [7:0] wide(int i);
    extern function iq_t que();
    extern static function int cnt();
  endclass
  function k_e c::pick(int i); return k_e'(i); endfunction
  function logic [7:0] c::wide(int i); return 8'(i); endfunction
  function iq_t c::que(); iq_t q; return q; endfunction
  function int c::cnt(); return 3; endfunction
endpackage
package p2; import p1::*; endpackage
package p3; import p1::*; endpackage
import p1::*;
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
