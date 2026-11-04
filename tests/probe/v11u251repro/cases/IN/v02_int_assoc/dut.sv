// § ifaceDynTdElabVar251 (an int associative typedef variable in an interface, two-state element)
typedef int a_t [int];
interface ifc;
  a_t m;
endinterface
module top; ifc i(); endmodule
