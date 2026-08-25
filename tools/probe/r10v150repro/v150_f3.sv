// r10v150 fence 3 — a BUILTIN method whose RECEIVER is a call  `f().size()`.
package fp3;
  typedef int iq_t[$];
  function iq_t qmk(); iq_t q; q.push_back(1); return q; endfunction
endpackage
module TF3;
  import fp3::*;
  function int h1(); return qmk().size(); endfunction
  int r; initial r = h1();
endmodule
