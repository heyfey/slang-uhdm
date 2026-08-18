// r10uvm98 arm a5 — the SECOND unresolved shape: a class's OWN typedef name
// written in an OUT-OF-BLOCK method definition, with the name CONTESTED by an
// alphabetically earlier class (the corpus `uvm_sequence_library::m_check`
// shape).  Plus the in-body prototype next to it, and more use sites.
package epk98;
  class a0win98 #(type T = int);          // alphabetically FIRST
    typedef a0win98 #(T) hot98_t;
    typedef int cold98_t;
  endclass

  class b1own98 #(type T = int);
    typedef b1own98 #(T) hot98_t;         // OWN declaration, contested
    typedef bit cold98_t;
    extern function void oob_hot(hot98_t p);        // prototype: in-body
    extern function void oob_cold(cold98_t p);
    function void inbody_hot(hot98_t p); endfunction
    task locals();
      hot98_t lv; cold98_t lc;
    endtask
  endclass
  function void b1own98::oob_hot(hot98_t p); endfunction
  function void b1own98::oob_cold(cold98_t p); endfunction

  class c2der98 extends b1own98 #(int);
    static function void st(hot98_t p); endfunction
    function hot98_t ret(); return null; endfunction
    task cast_it(); hot98_t h; $cast(h, null); endtask
  endclass
endpackage

module mtop98e;
  import epk98::*;
  a0win98 #(int) h1; b1own98 #(int) h2; c2der98 h3;
  initial begin h1 = new(); h2 = new(); h3 = new(); end
endmodule
