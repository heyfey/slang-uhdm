// r10v144 (VERIFIER) arm D — THE NAMED-BLOCK LOCAL AT CONTROL DEPTH 0.
// `CompileHelper::bindVariable` (CompileStmt.cpp:3089) switches on the scope's
// UhdmType and has cases for uhdmfunction / uhdmtask / uhdmbegin /
// uhdmmodule_inst and NO case for uhdmnamed_begin, so a NAMED block's
// Variables() are never searched and a local declared there cannot bind at
// COMPILE time, at ANY control-body depth.  r10uvm144's arm C `c12` only ever
// wrote its named block INSIDE an if body, where § controlBodyNoBind28 silences
// the reference for a different reason; this arm puts the named block at depth
// 0, where nothing else silences it.
package q144d;
  class B144D;
    extern static function void si(input int a);
  endclass
  function void B144D::si(input int a); endfunction
  function automatic void bare144d(input int a); endfunction

  // d01 SCOPED call, NAMED block at depth 0, in-body class method
  class D01; int w; function void m(); begin : nb01 int y; B144D::si(y); end w = 1; endfunction endclass
  // d02 BARE call, NAMED block at depth 0, in-body class method  (the pre-existing twin)
  class D02; int w; function void m(); begin : nb02 int y; bare144d(y); end w = 2; endfunction endclass
  // d03 SCOPED call, UNNAMED block at depth 0 (§ 57 says this one BINDS)
  class D03; int w; function void m(); begin int y; B144D::si(y); end w = 3; endfunction endclass
  // d04 BARE call, UNNAMED block at depth 0
  class D04; int w; function void m(); begin int y; bare144d(y); end w = 4; endfunction endclass
  // d05 SCOPED call, NAMED block INSIDE an if body (r10uvm144's own c12 shape)
  class D05; int w; function void m(); if (w == 1) begin : nb05 int y; B144D::si(y); end endfunction endclass
  // d06 SCOPED call, NAMED block at depth 0 in an OUT-OF-BODY method
  class D06; int w; extern function void m(); endclass
  function void D06::m(); begin : nb06 int y; B144D::si(y); end w = 6; endfunction
  // d07 SCOPED call, NAMED block at depth 0 in a PACKAGE FREE function
  function automatic void pf07(); begin : nb07 int y; B144D::si(y); end endfunction
  // d08 BARE call, NAMED block at depth 0 in a PACKAGE FREE function
  function automatic void pf08(); begin : nb08 int y; bare144d(y); end endfunction
  // d09 SCOPED call, NAMED block at depth 0 in a class TASK
  class D09; int w; task t(); begin : nb09 int y; B144D::si(y); end w = 9; endtask endclass
  // d10 SCOPED call, DOUBLY nested: unnamed block inside a named block
  class D10; int w; function void m(); begin : nb10 begin int y; B144D::si(y); end end w = 10; endfunction endclass
  // d11 SCOPED call, named block inside an UNNAMED block
  class D11; int w; function void m(); begin begin : nb11 int y; B144D::si(y); end end w = 11; endfunction endclass
  // d12 SCOPED call, the SUBROUTINE local read from inside a named block at depth 0
  class D12; int w; function void m(); int y; begin : nb12 B144D::si(y); end w = 12; endfunction endclass
  // d13 SCOPED call, a FORK arm that is NAMED
  class D13; int w; task t(); fork begin : nb13 int y; B144D::si(y); end join_none w = 13; endtask endclass
endpackage

module m144d;
  import q144d::*;
  int w;
  // d14 MODULE function, named block at depth 0, scoped call
  function automatic void mf14(); begin : nb14 int y; B144D::si(y); end endfunction
  // d15 MODULE function, named block at depth 0, bare call
  function automatic void mf15(); begin : nb15 int y; bare144d(y); end endfunction
  // d16 a MODULE CLASS in-body method
  class M16; int w; function void m(); begin : nb16 int y; B144D::si(y); end w = 16; endfunction endclass
endmodule
