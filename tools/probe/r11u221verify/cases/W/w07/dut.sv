// § tfArgImportCloneFollows216 — MiniAmiq's shape: the typedef's package sorts after the outside one, the outside package and an interface import it and call its function
package zp;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
  function automatic void g2(output e_t y2); y2 = A0; endfunction
endpackage
package aq;
  import zp::*;
  class N;
    function void h(e_t z); g(z); endfunction
  endclass
endpackage
interface ifc;
  import zp::*;
  e_t s;
  initial g2(s);
endinterface
module top;
  import zp::*;
  ifc u_ifc();
  e_t v;
endmodule
