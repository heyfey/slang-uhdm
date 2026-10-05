// § ifaceDynTdElabVar251 (an enum-typedef element queue in an interface)
typedef enum logic [1:0] {A, B} e_t;
typedef e_t q_t [$];
interface ifc;
  q_t q;
endinterface
module top; ifc i(); endmodule
