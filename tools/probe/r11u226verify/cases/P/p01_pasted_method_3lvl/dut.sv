// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — a method name pasted from two tokens (get_``N) inside a three-level macro chain, the receiver an actual
`define CALLM(O,N) O.get_``N()
`define LVL2(O,N) begin int r; r = `CALLM(O,N); end
`define LVL1(O,N) \
  begin \
    `LVL2(O,N) \
  end
package p;
class obj_c;
  function int get_id(); return 3; endfunction
  function int get_size(); return 4; endfunction
endclass
class user_c;
  obj_c h;
  function void run();
    `LVL1(h, id)
    `LVL1(h, size)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
