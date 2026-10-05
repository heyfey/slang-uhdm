// § clsEnumBaseRefFullName251 (builtin mode: a module-local class enum)
module top;
class c;
  typedef enum logic [2:0] {A, B} e_t;
  e_t m;
endclass
c h;
endmodule
