// § ifaceDynTdElabVar251 (a logic dynamic typedef in an interface passed through a generic interface port)
typedef logic [3:0] d_t [];
interface ifc;
  d_t d;
endinterface
module child(interface p); endmodule
module top; ifc i(); child c(.p(i)); endmodule
