// § ifaceDynTdElabVar251 (a bit dynamic typedef in an interface instantiated twice)
typedef bit [3:0] d_t [];
interface ifc;
  d_t d;
endinterface
module top; ifc i1(); ifc i2(); endmodule
