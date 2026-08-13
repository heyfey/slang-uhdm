// r10uvm64 arm b2 — THE NON-CLASS-METHOD TWINS.
//
// § controlBodyNoBind28 and everything layered on it are gated on
// `curSubClassScope9 && !curSubOob9` — an IN-BODY class method.  A module
// function, a package function and an out-of-body definition do not enter that
// gate at all, so this arm is the NEGATIVE CONTROL for the whole pass: if a
// cell here MOVES, the patch escaped its gate.
//
// SCOPE NAMES ARE MEASURED, NOT ASSUMED.  The first version of this arm wrote
// `m1` at FILE TOP LEVEL and called it "the module twin"; a top-level function
// is at $UNIT scope, which is § unitSubNoBind9's window and not a module's, and
// its cells read completely differently.  Both are kept, under their real
// names, because the difference is itself a measurement.
//
//   u<NN>_  $UNIT-scope function      (unitSubNoBind9)
//   m<NN>_  MODULE-scope function     (no silence law at all)
//   p<NN>_  PACKAGE-scope function
//   o<NN>_  OUT-OF-BODY class method  (curSubOob9)

function automatic int u1(input int farg);
  int r = 0;
  int bodyloc = 1;
  if (farg == 0) begin
    r = 100;
  end
  else begin
    int u01_blkloc = 2;
    if (u01_blkloc == 3) r = 2;           // u01 CONDITION, depth 1
    r = u01_blkloc;                       // u02 assignment RHS, depth 1
    if (bodyloc == 5) r = 5;              // u05 body local in a cond, depth 1
    return u01_blkloc;                    // u04 return operand, depth 1
  end
  return r;
endfunction

package b2p;
  function automatic int p1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int p01_blkloc = 2;
      if (p01_blkloc == 3) r = 2;         // p01 CONDITION, depth 1
      r = p01_blkloc;                     // p02 assignment RHS, depth 1
    end
    return r;
  endfunction
endpackage

class b2c;
  int prop;
  extern function int o1(input int farg);
endclass

// OUT-OF-BODY definition, compiled in the enclosing scope (curSubOob9).
function int b2c::o1(input int farg);
  int r = 0;
  int bodyloc = 1;
  if (farg == 0) begin
    int o01_blkloc = 2;
    if (o01_blkloc == 3) r = 2;           // o01 CONDITION, depth 1
    r = o01_blkloc;                       // o02 assignment RHS, depth 1
    if (bodyloc == 5) r = 5;              // o05 body local in a cond, depth 1
    if (prop == 6) r = 6;                 // o09 class property in a cond, d1
  end
  return r;
endfunction

module b2_top;
  b2c h;
  int r;

  // THE REAL MODULE TWIN.
  function automatic int m1(input int farg);
    int mr = 0;
    int bodyloc = 1;
    if (farg == 0) begin
      int m01_blkloc = 2;
      if (m01_blkloc == 3) mr = 2;        // m01 CONDITION, depth 1
      mr = m01_blkloc;                    // m02 assignment RHS, depth 1
      if (bodyloc == 5) mr = 5;           // m05 body local in a cond, depth 1
      return m01_blkloc;                  // m04 return operand, depth 1
    end
    return mr;
  endfunction

  initial begin
    h = new();
    r = u1(0);
    r = b2p::p1(0);
    r = h.o1(0);
    r = m1(0);
  end
endmodule
