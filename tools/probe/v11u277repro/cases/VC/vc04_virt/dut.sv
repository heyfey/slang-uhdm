// § ctorRetVarSiblingSpan277
interface ifc; logic a; endinterface
package p;
  typedef struct packed { logic [1:0] f; } st_t;
  typedef enum {E0, E1} e_t;
  class g1;
    function new(input virtual ifc vif);
    endfunction
  endclass
  class g2;
    function new(input st_t s);
    endfunction
  endclass
  class g3;
    function new(input e_t e = E1);
    endfunction
  endclass
  class g4;
    function new(input p::st_t s);
    endfunction
  endclass
  class g5;
    function new(input bit [1:0][2:0] m);
    endfunction
  endclass
endpackage
module top;
  ifc u();
  p::g1 x;
endmodule
