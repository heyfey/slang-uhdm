// § hcSelIdxInstName168
typedef struct packed { logic x; } S;
module mod(input S a);
endmodule
module dut(input [1:0] sel);
   S [3:0] sa;
   mod m(.a(sa[sel+1]));
endmodule
