// § hcSelIdxInstName168
typedef struct packed { logic [2:0] f; } S;
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input S s);
   mod m(.a(v[s.f]));
endmodule
