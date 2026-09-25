// § hcSelIdxInstName168
typedef struct packed { logic [1:0] x; } S;
module mod(input logic [1:0] a);
endmodule
module dut(input int sel);
   S [3:0] sa;
   mod m(.a(sa[sel].x));
endmodule
