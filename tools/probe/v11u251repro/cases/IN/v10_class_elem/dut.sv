// § ifaceDynTdElabVar251 (a class-element queue typedef in an interface)
class k; int a; endclass
typedef k q_t [$];
interface ifc;
  q_t q;
endinterface
module top; ifc i(); endmodule
