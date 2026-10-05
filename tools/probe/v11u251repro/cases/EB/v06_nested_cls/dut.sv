// § clsEnumBaseRefFullName251 (builtin mode: a class nested in a class, control: the law does not fire)
package p;
class o;
  class c;
    typedef enum bit [1:0] {A, B} e_t;
    e_t m;
  endclass
endclass
endpackage
module top; endmodule
