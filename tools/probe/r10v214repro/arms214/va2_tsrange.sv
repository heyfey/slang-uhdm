// v214 arm 2 — TYPESPEC RANGES inside a def clone listing: a formal's range, a
// body local's range, and the return range, all spelled with the package's own
// parameter.  The population table claims these already agreed; a law that
// widened would move them.
package pv2;
  parameter int W2 = 8;
  parameter W2B = W2;
  function automatic int sink2(int a); return a; endfunction
  class C2;
    extern function logic [W2-1:0] rd_ret2(logic [W2B-1:0] a);
    extern function int rd_loc2();
  endclass
  function logic [W2-1:0] C2::rd_ret2(logic [W2B-1:0] a);
    return a;
  endfunction
  function int C2::rd_loc2();
    logic [W2-1:0] loc;
    logic [W2B-1:0] loc2;
    loc = '0; loc2 = '0;
    return sink2(int'(loc) + int'(loc2) + W2);
  endfunction
endpackage
module topv2;
  pv2::C2 c = new();
  int x;
  initial x = c.rd_loc2();
endmodule
