// § tfArgDefTopSplit176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
endpackage
interface ifc;
  import p::*;
  function automatic int h(e_t k);
    return int'(k) + 1;
  endfunction
endinterface
module top (output int o1, o2);
  ifc i ();
  assign o1 = p::f(p::B);
  assign o2 = i.h(p::C);
endmodule
