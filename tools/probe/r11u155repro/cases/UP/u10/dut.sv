// § nonAnsiArrayNetAtHeader155
typedef struct packed { logic [5:0] third; } struct2;
module sub(var3);
  output struct2 var3 [3];
  for (genvar i=0; i<3; i++) begin : g
    assign var3[i] = struct2'(127);
  end
endmodule
module dut(output struct2 o [3]); sub u(o); endmodule
