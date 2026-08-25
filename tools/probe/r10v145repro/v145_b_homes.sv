// r10v145 arm B -- HOMES x production, 1-3 instances each.
// package class / $unit class / module class / interface / program /
// interface class (prototype only) / nested class.  MEASUREMENT ONLY.

// ---------- $unit (compilation-unit) class ----------
class Cu145v;
  int f;
  function void um1145v;              // TF-ITEM (paren-less)
    int u1 = 1;
    int u2 = 2;
    $display(u1, u2);
    $display(u1);
  endfunction
  function void um2145v();            // BLOCK-ITEM twin
    int u1 = 1;
    int u2 = 2;
    $display(u1, u2);
    $display(u1);
  endfunction
  task ut1145v;                       // TF-ITEM task (body io)
    input int p;
    int u3 = 3;
    $display(u3, p);
    $display(u3);
  endtask
endclass

package pb145v;
  // ---------- package class ----------
  class Cp145v;
    int f;
    function void pm1145v;
      int a1 = 1;
      int a2 = 2;
      $display(a1, a2);
      $display(a1);
    endfunction
    function void pm2145v();
      int a1 = 1;
      int a2 = 2;
      $display(a1, a2);
      $display(a1);
    endfunction
    task pt1145v;
      input int p;
      int a3 = 3;
      $display(a3, p);
      $display(a3);
    endtask
    // three instances of the same TF-ITEM shape in one class
    function void pm3145v;
      int b1 = 1;
      $display(b1);
      $display(b1 + 1);
    endfunction
    function void pm4145v;
      int b1 = 1;
      $display(b1);
      $display(b1 + 1);
    endfunction
  endclass

  // ---------- nested class ----------
  class Cn145vOuter;
    typedef class Cn145vInner;
    class Cn145vInner;
      function void nm1145v;
        int n1 = 1;
        int n2 = 2;
        $display(n1, n2);
        $display(n1);
      endfunction
    endclass
  endclass

  // ---------- interface class: prototypes only ----------
  interface class Ic145v;
    pure virtual function int ip1145v(int a);
  endclass

  // ---------- package free subroutines ----------
  function void pf1145v;
    int g1 = 1;
    int g2 = 2;
    $display(g1, g2);
    $display(g1);
  endfunction
endpackage

// ---------- module class + module subroutines ----------
module m145v;
  class Cm145v;
    function void mm1145v;
      int c1 = 1;
      int c2 = 2;
      $display(c1, c2);
      $display(c1);
    endfunction
    function void mm2145v();
      int c1 = 1;
      int c2 = 2;
      $display(c1, c2);
      $display(c1);
    endfunction
  endclass
  function void mf1145v;
    int d1 = 1;
    int d2 = 2;
    $display(d1, d2);
    $display(d1);
  endfunction
  task mt1145v;
    input int p;
    int d3 = 3;
    $display(d3, p);
    $display(d3);
  endtask
endmodule

// ---------- interface ----------
interface if145v;
  class Ci145v;
    function void im1145v;
      int e1 = 1;
      int e2 = 2;
      $display(e1, e2);
      $display(e1);
    endfunction
  endclass
  function void ifn1145v;
    int e3 = 1;
    int e4 = 2;
    $display(e3, e4);
    $display(e3);
  endfunction
endinterface

// ---------- program ----------
program pg145v;
  class Cg145v;
    function void gm1145v;
      int h1 = 1;
      int h2 = 2;
      $display(h1, h2);
      $display(h1);
    endfunction
  endclass
  function void gf1145v;
    int h3 = 1;
    int h4 = 2;
    $display(h3, h4);
    $display(h3);
  endfunction
endprogram

module top145v;
  m145v i_m();
  if145v i_if();
endmodule
