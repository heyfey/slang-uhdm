// § ifaceDynTdElabVar251 (a logic queue typedef in an interface instance array)
typedef logic [7:0] q_t [$];
interface ifc;
  q_t q;
endinterface
module top; ifc i[2](); endmodule
