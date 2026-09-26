// § castRhsClonePerInst176
interface ifc(input logic [3:0] w);
   assign a = int'(w);
endinterface
module top();
   logic [3:0] w;
   ifc i1(w);
   ifc i2(w);
endmodule
