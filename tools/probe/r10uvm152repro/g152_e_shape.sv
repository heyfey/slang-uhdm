// r10uvm152 arm E — THE SHAPES of the eaten first body element.  ONE
// out-of-body EMPTY-PAREN constructor per shape, the shape always FIRST.
package pe152;

  class Ke152;
    int qe;
  endclass
  class Ge152 #(type T = int, int W = 1);
    T ge;
  endclass
  typedef Ke152 ke_td152;
  typedef Ge152#(int, 3) ge_spec152;

  function void esink152(int x); endfunction

  // e1 — ONE class-handle declarator
  class E1e152; int z; extern function new(); endclass
  function E1e152::new();
    Ke152 e1_a;
    e1_a = null; z = 1;
  endfunction

  // e2 — THREE declarators in ONE declaration (one grammar element)
  class E2e152; int z; extern function new(); endclass
  function E2e152::new();
    Ke152 e2_a, e2_b, e2_c;
    e2_a = null; e2_b = null; e2_c = null; z = 2;
  endfunction

  // e3 — TWO separate declarations: only the FIRST is eaten
  class E3e152; int z; extern function new(); endclass
  function E3e152::new();
    Ke152 e3_a;
    Ke152 e3_b;
    e3_a = null; e3_b = null; z = 3;
  endfunction

  // e4 — a TYPEDEF'd handle
  class E4e152; int z; extern function new(); endclass
  function E4e152::new();
    ke_td152 e4_a;
    e4_a = null; z = 4;
  endfunction

  // e5 — a PARAMETERIZED class handle, written specialization
  class E5e152; int z; extern function new(); endclass
  function E5e152::new();
    Ge152#(int, 3) e5_a;
    e5_a = null; z = 5;
  endfunction

  // e6 — a typedef of a parameterized specialization
  class E6e152; int z; extern function new(); endclass
  function E6e152::new();
    ge_spec152 e6_a;
    e6_a = null; z = 6;
  endfunction

  // e7 — an UNPACKED ARRAY of handles
  class E7e152; int z; extern function new(); endclass
  function E7e152::new();
    Ke152 e7_a[4];
    e7_a[0] = null; z = 7;
  endfunction

  // e8 — a QUEUE of handles
  class E8e152; int z; extern function new(); endclass
  function E8e152::new();
    Ke152 e8_a[$];
    e8_a.delete(); z = 8;
  endfunction

  // e9 — non-class kinds: int / string / logic vector / real
  class E9e152; int z; extern function new(); endclass
  function E9e152::new();
    int e9_i;  
    string e9_s;
    logic [7:0] e9_v;
    real e9_r;
    e9_i = 1; e9_s = ""; e9_v = 8'h0; e9_r = 0.0; z = 9;
  endfunction

  // e10 — an INITIALISED first declarator
  class E10e152; int z; extern function new(); endclass
  function E10e152::new();
    int e10_i = 7;
    esink152(e10_i); z = 10;
  endfunction

  // e11 — an associative array of handles
  class E11e152; int z; extern function new(); endclass
  function E11e152::new();
    Ke152 e11_a[string];
    e11_a["x"] = null; z = 11;
  endfunction

endpackage

module me152;
  import pe152::*;
  initial begin
    E1e152 c1; E2e152 c2; E3e152 c3; E4e152 c4; E5e152 c5; E6e152 c6;
    E7e152 c7; E8e152 c8; E9e152 c9; E10e152 c10; E11e152 c11;
    c1 = new(); c2 = new(); c3 = new(); c4 = new(); c5 = new(); c6 = new();
    c7 = new(); c8 = new(); c9 = new(); c10 = new(); c11 = new();
  end
endmodule
