// § clsEnumBaseRefFullName251 (builtin mode: a class declared inside an interface)
interface ifc;
class c;
  typedef enum bit [1:0] {A, B} e_t;
  e_t m;
endclass
endinterface
module top; ifc i(); endmodule
