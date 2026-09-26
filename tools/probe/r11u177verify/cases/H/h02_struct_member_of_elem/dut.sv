// § hcSelIdxInstName168
module mod(input logic a);
endmodule
typedef struct packed { logic [2:0] f; logic g; } s_t;
module dut(input logic [7:0] v, input s_t sa [2]);
  mod m(.a(v[sa[1].f]));
endmodule
