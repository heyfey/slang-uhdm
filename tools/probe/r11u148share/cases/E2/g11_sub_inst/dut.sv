module sub(output int o);
   parameter int X = 1;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = X + 3;
      assign o = L;
   end
endmodule
module top(output int o);
   sub #(.X(5)) u(.o(o));
endmodule
