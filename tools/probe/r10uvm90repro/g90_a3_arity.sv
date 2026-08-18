// r10uvm90 arm a3 — the ARITY shapes, kept as a REFUTATION and never as a
// measurement: slang-uhdm REFUSES this file (3 errors, no output), so none of
// these three constructor-call shapes can appear in any database in either
// corpus.  Run it to re-confirm that; it is expected to print NO_OUTPUT.
class w3comp;
  int q;
  function new(string name);
    q = 1;
  endfunction
endclass

virtual class w3base;
  int m;
  function new (string name, w3comp parent, int a=0, int b=1);
    m = a;
  endfunction
endclass

// b2  TOO FEW actuals for a formal with NO default (`parent`).
class w3b2 #(type IMP=int) extends w3base;
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name);
    m_imp = imp;
  endfunction
endclass

// b3  TOO MANY actuals.
class w3b3 #(type IMP=int) extends w3base;
  local IMP m_imp;
  function new (string name, IMP imp, w3comp p);
    super.new (name, p, 1, 1, 9, 9);
    m_imp = imp;
  endfunction
endclass

// b5  a NAMED actual naming a formal that does not exist.
class w3b5 #(type IMP=int) extends w3base;
  local IMP m_imp;
  function new (string name, IMP imp, w3comp p);
    super.new (.name(name), .parent(p), .nosuch(3));
    m_imp = imp;
  endfunction
endclass
