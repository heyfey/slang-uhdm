// § cloneTfItemLocalOwnVar253 (control: a paren-less task blockifies)
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
    int x;
    int y;
    x = 1;
    y = x + 1;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
