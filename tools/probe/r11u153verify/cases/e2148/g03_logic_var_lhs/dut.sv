// § genLpUintCaRhsOwnCopy148
module top(output logic [7:0] o);
   logic [7:0] v;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int unsigned K = 5;
      assign v = K;
   end
   assign o = v;
endmodule
