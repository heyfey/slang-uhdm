// § unionRetVarAtTypeToken237
// a class method returning a package union typedef, qualified
package p;
  typedef union packed { int unsigned i; bit [31:0] v; } u_t;
class c;
  function p::u_t g();
    return 0;
  endfunction
endclass
endpackage
module top;
endmodule
