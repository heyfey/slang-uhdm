// § genLpUintCaRhsOwnCopy148
module sub #(parameter int X = 1) (output int o);
   if (1) begin : g
      localparam int Offset = X + 1;
      assign o = Offset;
   end
endmodule
module top(output int o, output int p);
   sub #(.X(4)) u1(.o(o));
   sub u2(.o(p));
endmodule
