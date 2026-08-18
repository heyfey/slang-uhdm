// v93 B1 — parameterised class member type + class-scoped types as slice_size.
class Cp #(int W = 8);
  typedef logic [W-1:0] w_t;
  typedef logic [3:0]   f_t;
  logic [63:0] m;
  function logic [63:0] f(logic [63:0] v);
    return { << w_t { v } };
  endfunction
  function logic [63:0] g(logic [63:0] v);
    return { << f_t { v } };
  endfunction
endclass
typedef Cp#(16) C16;
module b1_ptype;
  typedef Cp#(4)::f_t cf_t;
  logic [63:0] v, r0, r1;
  initial begin
    r0 = { << C16::f_t { v } };
    r1 = { << cf_t     { v } };
  end
endmodule
