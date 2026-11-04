// § ppIdentEndInRebuiltText219 — a pasted method name (`get_``M`) and a pasted object name after a multi-line trace body
`define TRACE(MSG) \
  begin \
    if (1) \
      $display("%s", \
        MSG); \
  end
`define CALL(OBJ, M, ARG) \
  begin \
    `TRACE($sformatf(`"calling get_M on OBJ`")) \
    OBJ.get_``M(ARG); \
    OBJ``_b.get_``M(ARG); \
  end
package p;
class c;
  c c_a;
  c c_a_b;
  function int get_name(int a); return a; endfunction
  function void run(int x);
    `CALL(c_a, name, x)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
