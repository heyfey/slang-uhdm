// § regTdArrElabIsNet251 (a reg queue typedef in an interface with a modport port view)
typedef reg q_t [$];
interface ifc;
  q_t q;
  logic x;
  modport mp(input x);
endinterface
module child(ifc.mp p); endmodule
module top; ifc i(); child c(.p(i)); endmodule
