// § genLpOperandTsNoParent152
interface ifc;
   parameter int P [2]  = '{1, 2};
   int o;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int A = P[1];
      assign o = A;
   end
endinterface
module top(output int o);
  ifc u();
  assign o = u.o;
endmodule
