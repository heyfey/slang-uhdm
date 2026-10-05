// § clsEnumBaseRefFullName251 (builtin mode: the class enum used only as a method formal)
package p;
class c;
  typedef enum bit [1:0] {A, B} e_t;
  function void f(e_t x); endfunction
endclass
endpackage
module top; endmodule
