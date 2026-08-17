// vsd12 cell vc — THE CONTAINERS grid12 does not visit.  `h4` reaches a MODULE
// `initial` body; a PROGRAM body, an INTERFACE task, a GENERATE-block
// `initial`, and an `always_comb` body are the same StmtEmit block-item site
// under four different enclosing symbols, and `tdDeclCtx10`'s walk stops at
// `InstanceBody` for all of them.  A class declared INSIDE an interface is the
// one shape where the OWNER's parent scope is an InstanceBody rather than a
// Package, which is the term `rootNameable` turns on.
package pvc;
  class zelvc;
    int q;
  endclass
  class zownc;                      // sorts late; the ClassVar arm
    typedef zelvc d_t;
    typedef int   i_t;
  endclass
endpackage

interface ifc();
  import pvc::*;
  class iowner;                     // a class declared INSIDE an interface
    typedef int t_t;
  endclass
  task automatic it();
    zownc::d_t  if_q[$];            // INTERFACE task body
    iowner::t_t if_i[$];            // owner's parent scope is an InstanceBody
    if_q = {};
    if_i = {};
  endtask
endinterface

program prgc();
  import pvc::*;
  initial begin
    zownc::d_t pg_q[$];             // PROGRAM body
    zownc::i_t pg_i[2];
    pg_q = {};
  end
endprogram

module topvc;
  import pvc::*;
  ifc u_ifc();
  prgc u_prg();
  for (genvar g = 0; g < 2; g++) begin : gb
    initial begin
      zownc::d_t gb_q[$];           // GENERATE-block `initial` body
      gb_q = {};
    end
  end
  always_comb begin
    zownc::d_t ac_q[$];             // `always_comb` body
    ac_q = {};
  end
endmodule
