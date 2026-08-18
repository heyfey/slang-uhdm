// r10uvm90 arm a1 — the corpus head reproduced in miniature.
// UVM_IMP_COMMON's shape: a GENERIC class whose type parameter defaults to
// `int` passes that parameter's variable as the SECOND actual of a
// `super.new (...)` whose FORMAL is a CLASS HANDLE.
class w1comp;
  string nm;
  function new(string name);
    nm = name;
  endfunction
endclass

typedef enum { W1_PORT, W1_IMPLEMENTATION } w1_port_type_e;

virtual class w1base #(type IF=int);
  int m_if_mask;
  int m_port_type;
  function new (string name,
                w1comp parent,
                w1_port_type_e port_type,
                int min_size=0,
                int max_size=1);
    m_port_type = port_type;
  endfunction
endclass

class w1ifb #(type T1=int, type T2=int);
  int dummy;
endclass

// A. the head shape: IMP defaults to int, so `imp` is an int handed to a
//    `w1comp parent` formal.  A TYPE ERROR in slang, invisible to Surelog.
class w1imp #(type T=int, type IMP=int) extends w1base #(w1ifb #(T,T));
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp, W1_IMPLEMENTATION, 1, 1);
    m_imp = imp;
    m_if_mask = 1;
  endfunction
endclass

// B. the CONTROL: identical text, but the type parameter defaults to the
//    class the formal wants, so slang binds the super.new.
class w1ok #(type T=int, type IMP=w1comp) extends w1base #(w1ifb #(T,T));
  local IMP m_imp;
  function new (string name, IMP imp);
    super.new (name, imp, W1_IMPLEMENTATION, 1, 1);
    m_imp = imp;
    m_if_mask = 2;
  endfunction
endclass

// C. control: NO type parameter at all, plain class handle actual.
class w1plain extends w1base #(int);
  int m_x;
  function new (string name, w1comp imp);
    super.new (name, imp, W1_IMPLEMENTATION, 1, 1);
    m_x = 3;
    m_if_mask = 3;
  endfunction
endclass

// D. control: the SPACE before the parens, on a binding call.
class w1space extends w1base #(int);
  int m_y;
  function new (string name, w1comp imp);
    super.new(name, imp, W1_IMPLEMENTATION, 1, 1);
    m_y = 4;
    m_if_mask = 4;
  endfunction
endclass

module w1top;
  // w1imp deliberately NOT instantiated: the DEFAULT specialization is the
  // one the corpus compares, and slang SUPPRESSES diagnostics inside it.
  w1ok  #(int)     b;
  w1plain          c;
  w1space          d;
endmodule
