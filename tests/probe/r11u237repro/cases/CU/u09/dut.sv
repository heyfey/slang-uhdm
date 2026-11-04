// § clsTdUnionBuilt237
// the union typedef as a method's local variable
package p;
class c;
  typedef union packed { int unsigned i; bit [31:0] v; } u_t;
  function int f();
    u_t t;
    t.i = 3;
    return t.v;
  endfunction
endclass
endpackage
module top;
endmodule
