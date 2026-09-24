// r10uvm90 arm a2 — every way slang can WRAP a constructor call in an
// InvalidExpression, and the negative controls.  EVERY cell lives inside a
// GENERIC class's DEFAULT specialization, because that is the only scope where
// slang SUPPRESSES the diagnostic — outside it the tool refuses the file and
// nothing is measured (arm a1's first cut, `NO_OUTPUT`).
class w2comp;
  int q;
  function new(string name);
    q = 1;
  endfunction
endclass

virtual class w2base;
  int m;
  function new (string name, w2comp parent, int a=0, int b=1);
    m = a;
  endfunction
endclass

class w2one;
  int z;
  function new (string name, w2comp parent);
    z = 2;
  endfunction
endclass

// THE ARITY SHAPES ARE NOT HERE.  `too few arguments` / `too many arguments` /
// `argument '<x>' does not exist` are NOT suppressed inside a generic class's
// default specialization (measured: g90_a3_arity.sv, which slang-uhdm REFUSES
// outright, 3 errors, NO OUTPUT AT ALL).  A database therefore cannot contain
// such a call, and the only `InvalidExpression`-wrapped constructor call that
// reaches one is a CONVERSION failure -- which is exactly what the law's gate
// is keyed on reaching.
//
// b1  THE HEAD SHAPE: a type-mismatched POSITIONAL actual (int -> class handle).
class w2b1 #(type IMP=int) extends w2base;
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp, 1, 1);
    m_imp = imp;
  endfunction
endclass

// b4  a BARE `new(...)` whose TARGET binds but whose ACTUAL does not.
class w2b4 #(type IMP=int);
  w2one h;
  local IMP m_imp;
  function new (string name, IMP imp);
    h = new(name, imp);
    m_imp = imp;
  endfunction
endclass

// b6  a type-mismatched actual that is an EXPRESSION, not a plain identifier.
class w2b6 #(type IMP=int) extends w2base;
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp + 1, 1, 1);
    m_imp = imp;
  endfunction
endclass

// b7  INTENDED as "the mismatch on the LAST actual instead of the second", AND
//     IT IS NOT ONE: `imp` is an int and so is w2base::new's `int b` formal, so
//     slang BINDS it and the cell is an ACCIDENTAL control that AGREES on both
//     binaries.  It is left here, named for what it is rather than recounted as
//     a control that was designed on purpose (ARMS.r10uvm90.txt says the same).
class w2b7 #(type IMP=int) extends w2base;
  local IMP m_imp;
  function new (string name, w2comp p, IMP imp);
    super.new (name, p, 1, imp);
    m_imp = imp;
  endfunction
endclass

// b8  CONTROL: a generic class whose super.new binds cleanly.
class w2b8 #(type IMP=w2comp) extends w2base;
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp, 1, 1);
    m_imp = imp;
  endfunction
endclass

// b9  CONTROL: NON-generic, everything binds.
class w2b9 extends w2base;
  int y;
  function new (string name, w2comp imp);
    super.new (name, imp, 1, 1);
    y = 5;
  endfunction
endclass

// b10 CONTROL: a PORT-LESS constructor with a mismatched super.new — the
//     § constructorBodyElementShift27 interaction (golden EATS the first body
//     element when there is no port list, so this cell must NOT gain a call).
class w2b10 #(type IMP=int) extends w2base;
  local IMP m_imp;
  int w;
  function new ();
    super.new ("x", m_imp, 1, 1);
    w = 6;
  endfunction
endclass

module w2top;
  w2b9 c9;
endmodule
