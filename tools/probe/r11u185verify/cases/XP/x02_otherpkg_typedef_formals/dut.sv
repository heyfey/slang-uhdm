// § externProtoFormalsFromPrototype175
package pa;
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package pb;
  class k;
    extern function void put(pa::s_t v,
      pa::e_t e = pa::B);
  endclass
  function void k::put(pa::s_t v, pa::e_t e = pa::B);
    $display("%0d %0d", v.x, e);
  endfunction
endpackage
module top;
  import pb::*;
  k o;
  initial begin o = new; o.put('{4'd1, 1'b0}); end
endmodule
