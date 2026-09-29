// § tfArgScalarTdWriter223 — class-method formals of every scalar keyword typedef: int, integer, byte, shortint, longint, bit, logic, reg
package p;
  typedef int      t_int;
  typedef integer  t_integer;
  typedef byte     t_byte;
  typedef shortint t_short;
  typedef longint  t_long;
  typedef bit      t_bit;
  typedef logic    t_logic;
  typedef reg      t_reg;
  class c;
    function void f(t_int a, t_integer b, t_byte d, t_short e, t_long g, t_bit h, t_logic i, t_reg j); endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
