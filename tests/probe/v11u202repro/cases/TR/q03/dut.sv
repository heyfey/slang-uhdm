// § classTdRetSharesTypedefTs200
package p;
  class cb #(type T = int, type CB = int);
    typedef cb #(T, CB) this_type;
    static this_type m_inst;
    static function this_type get();
      if (m_inst == null) m_inst = new;
      return m_inst;
    endfunction
  endclass
  class obj; endclass
  class obj_cb; endclass

  typedef cb #(obj, obj_cb) obj_cbs_t;
  class user;
    obj_cbs_t h;
    function void f();
      h = obj_cbs_t::get();
    endfunction
  endclass
endpackage
module q03; endmodule
