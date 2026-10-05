// § ifaceDynTdElabVar251 (a logic queue typedef in an interface passed through a modport port)
typedef logic [3:0] q_t [$];
interface ifc;
  q_t q;
  logic x;
  modport mp(input x);
endinterface
module child(ifc.mp p); endmodule
module top; ifc i(); child c(.p(i)); endmodule
