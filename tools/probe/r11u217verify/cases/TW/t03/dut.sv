// § twinElemOnlyNoRange209 — r11u217 t03: a MODULE-scope class returning a queue typedef of a module typedef, an extern method with an out-of-body return, and a static method returning a dynamic array of a parameterized class
module top;
  typedef logic [7:0] b_t;
  class w #(int N = 2); b_t v [N]; endclass
  class c;
    typedef b_t qb_t[$];
    typedef w#(3) dw_t[];
    extern function qb_t fq();
    static function dw_t fd(); dw_t r; return r; endfunction
  endclass
  function c::qb_t c::fq(); qb_t r; r.push_back(8'h1); return r; endfunction
  c h;
endmodule
