// § externProtoFormalsFromPrototype175
package pa;
  typedef enum {RED, GREEN, BLUE} col_e;
endpackage
package pb;
  import pa::*;
  class k;
    extern function col_e next(col_e c = GREEN, int unsigned step = 1);
  endclass
  function col_e k::next(col_e c = GREEN, int unsigned step = 1);
    return col_e'((c + step) % 3);
  endfunction
endpackage
module top;
  import pb::*;
  import pa::*;
  k o; col_e r;
  initial begin o = new; r = o.next(); end
endmodule
