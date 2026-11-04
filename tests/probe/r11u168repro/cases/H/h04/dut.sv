// § hcSelIdxInstName168
typedef struct packed { logic x; } S;
module mod(input S a);
endmodule
module dut(input int sel);
   S sa [3:0];
   mod m(.a(sa[sel]));
endmodule
