// § nonAnsiArrayNetAtHeader155
module dut(a, var3);
  typedef struct packed { logic [5:0] third; } struct2;
  input a;
  output struct2 var3 [2:0];
  assign var3[0] = struct2'(1);
endmodule
