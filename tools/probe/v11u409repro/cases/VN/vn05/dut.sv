// § impEnumParamRefNoSize409
package p;
  typedef enum { A, B, C } e_t;
  parameter e_t P = C;
endpackage
interface ifc;
  import p::*;
  logic [1:0] s = P;
endinterface
module top;
  ifc i();
endmodule
