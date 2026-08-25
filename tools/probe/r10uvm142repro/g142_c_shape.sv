// r10uvm142 arm C — SPELLING and MULTIPLICITY, under both productions.
// typedef'd handles, PARAMETERIZED classes (written `#(...)` and bare),
// one/two/three declarators on one statement, arrays of handles, a `static`
// declaration, and a handle whose class is EXTENDED.
package pc142;
  class Bc142;
    int f;
  endclass
  class Kc142 #(type Tc142 = int, int Nc142 = 2) extends Bc142;
    Tc142 g;
  endclass
  typedef Kc142#(int, 3) tspec142;
  typedef Bc142          tbase142;

  class Hc142;
    extern function void ctf;
    extern function void cbl();
  endclass

  function void Hc142::ctf;
    Bc142            c_one;
    Bc142            c_two_a, c_two_b;
    Bc142            c_three_a, c_three_b, c_three_c;
    tbase142         c_td;
    Kc142            c_bare;
    Kc142#(int, 3)   c_spec;
    tspec142         c_tdspec;
    static Bc142     c_static;
    Bc142            c_arr [3];
    Bc142            c_q [$];
  endfunction
  function void Hc142::cbl();
    Bc142            d_one;
    Bc142            d_two_a, d_two_b;
    Bc142            d_three_a, d_three_b, d_three_c;
    tbase142         d_td;
    Kc142            d_bare;
    Kc142#(int, 3)   d_spec;
    tspec142         d_tdspec;
    static Bc142     d_static;
    Bc142            d_arr [3];
    Bc142            d_q [$];
  endfunction
  function void cpftf;
    Bc142            e_one;
    tbase142         e_td;
    Kc142            e_bare;
    Kc142#(int, 3)   e_spec;
    tspec142         e_tdspec;
  endfunction
  function void cpfbl();
    Bc142            f_one;
    tbase142         f_td;
    Kc142            f_bare;
    Kc142#(int, 3)   f_spec;
    tspec142         f_tdspec;
  endfunction
  // controls at package / class scope
  Bc142          cpkg_one;
  tbase142       cpkg_td;
  Kc142#(int, 3) cpkg_spec;
endpackage
