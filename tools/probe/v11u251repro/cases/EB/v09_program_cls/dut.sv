// § clsEnumBaseRefFullName251 (builtin mode: a class declared inside a program)
program pr;
class c;
  typedef enum bit [1:0] {A, B} e_t;
  e_t m;
endclass
endprogram
module top; endmodule
