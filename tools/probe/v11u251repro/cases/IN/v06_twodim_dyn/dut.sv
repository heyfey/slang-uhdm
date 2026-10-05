// § ifaceDynTdElabVar251 (a two-level dynamic typedef in an interface)
typedef logic [3:0] d_t [][];
interface ifc;
  d_t d;
endinterface
module top; ifc i(); endmodule
