// § defImpArithSize32_409
package p;
  parameter R = 3'd2 + 3'd1;
endpackage
interface ifc;
  import p::*;
  logic [2:0] s = R;
endinterface
module top;
  ifc i();
endmodule
