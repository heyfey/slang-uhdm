module adder(a_if.port inter, a_if.port out_inter);
  always_ff @(posedge inter.clk) out_inter.A <= inter.A;
endmodule
