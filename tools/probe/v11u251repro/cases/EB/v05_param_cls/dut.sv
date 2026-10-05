// § clsEnumBaseRefFullName251 (builtin mode: a parameterized class enum, specialized twice)
package p;
class c #(int W=1);
  typedef enum bit [1:0] {A, B} e_t;
  e_t m;
endclass
endpackage
module top; p::c#(2) h2; p::c#(3) h3; endmodule
