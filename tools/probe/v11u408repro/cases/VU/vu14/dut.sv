// § classImpTdParamTsClone408
package p;
  typedef logic [7:0] ft_t;
  parameter ft_t A = 8'h3;
endpackage
import p::*;
class c;
  ft_t v;
  function ft_t get(); return A; endfunction
endclass
module top;
  c h;
  initial h = new;
endmodule
