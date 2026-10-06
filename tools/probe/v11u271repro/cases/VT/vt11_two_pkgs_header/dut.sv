// § tpUseSharesOwnTs271
package pa;
  class obj; endclass
  `include "reg.svh"
  class sa extends obj; typedef reg_c #(sa) type_id; endclass
endpackage
package pb;
  class obj; endclass
  `include "reg.svh"
  class sb extends obj; typedef reg_c #(sb) type_id; endclass
endpackage
module top;
  pa::sa a;
  pb::sb b;
endmodule
