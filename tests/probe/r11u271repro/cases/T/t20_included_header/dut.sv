// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
`include "reg_c.svh"
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, "sbase") type_id;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
