// § ifaceDynTdElabVar251 (a string queue typedef variable in an interface)
typedef string s_t [$];
interface ifc;
  s_t q;
endinterface
module top; ifc i(); endmodule
