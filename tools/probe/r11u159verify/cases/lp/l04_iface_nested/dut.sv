// § genLpOperandTsNoParent152
interface bus_if;
   parameter int P [2] = '{1, 2};
   int v;
   for (genvar i = 0 ; i < 1 ; i++) begin : a
      for (genvar j = 0 ; j < 1 ; j++) begin : b
         localparam int L = P[1];
         assign v = L;
      end
   end
endinterface
module top(output int o);
   bus_if u();
   assign o = u.v;
endmodule
