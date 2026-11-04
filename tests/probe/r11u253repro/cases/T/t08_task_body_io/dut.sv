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
  task automatic t;
    input int a;
    int x;
    x = a;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
