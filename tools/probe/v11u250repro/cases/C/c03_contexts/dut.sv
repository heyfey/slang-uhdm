// § pkgArrTdBindCopies250
// the typedef in an interface body, a generate-for block, a named begin block, a function local and a task with a qualified name
package p;
  typedef logic [3:0] a_t [2];
  typedef int q_t [$];
endpackage
interface ifc;
  import p::*;
  a_t iv;
endinterface
module top(input logic [3:0] i, output logic [3:0] o);
  import p::*;
  ifc u();
  p::a_t qv;
  wire logic [3:0] wn [2];
  for (genvar g = 0; g < 2; g++) begin : gb
    a_t gv;
    assign gv[0] = i;
    assign gv[1] = i;
  end
  function automatic logic [3:0] f(input logic [3:0] x);
    a_t lv;
    lv[0] = x;
    return lv[0];
  endfunction
  always_comb begin : blk
    a_t bv;
    bv[1] = i;
    qv = bv;
    u.iv = qv;
  end
  assign o = f(gb[1].gv[0]) ^ u.iv[1] ^ qv[0];
endmodule
