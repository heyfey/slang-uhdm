// § cloneTfItemLocalOwnVar253
package p;
  class root_t;
    int k;
    static function root_t get_inst();
      return null;
    endfunction
  endclass
  class cs_t;
    static cs_t inst;
    static function cs_t get();
      return inst;
    endfunction
    virtual function root_t get_root();
      return null;
    endfunction
  endclass
  class comp;
    extern function void m_set();
  endclass
  function void comp::m_set;
    root_t clp = root_t::get_inst();
    root_t top;
    cs_t cs;
    cs = cs_t::get();
    top = cs.get_root();
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
