// § nonAnsiArrayNetAtHeader155
module dut(var3);
  output var3;
  logic [5:0] var3 [7];
  for (genvar i=0; i<7; i++) begin : g
    assign var3[i] = 6'd1;
  end
endmodule
