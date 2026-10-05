// § clsTdUnionBuilt237
// control: the struct twin of u04 (a struct typedef as a method formal and return)
package p;
class c;
  typedef struct packed { int unsigned i; bit [31:0] v; } u_t;
  function u_t f(u_t a);
    return a;
  endfunction
endclass
endpackage
module top;
endmodule
