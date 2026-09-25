// § nonAnsiArrayNetAtHeader155
module dut(var3);
  typedef struct packed { logic [5:0] third; } struct2;
  output struct2 var3 [7];
  wire struct2 w [2];
  assign var3[0] = struct2'(1);
endmodule
