// VERIFIER CELL g01 - THE DROP HALF: an UNBOUND scoped call whose ARGUMENT is a
// BOUND scoped call.  Golden drops the whole argument list; does ours drop the
// inner (already-emittable) object too, or does something else emit it?
package p59g01;
  class conc59;
    static function conc59 get(); return null; endfunction
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      T v = T::getn(conc59::get(), 7);
      m_flag = 1;
    endfunction
  endclass
endpackage
