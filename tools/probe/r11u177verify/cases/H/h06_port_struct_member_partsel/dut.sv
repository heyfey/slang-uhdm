// § hcSelIdxInstName168
module mod(input logic a);
endmodule
typedef struct packed { logic [3:0] idx; logic e; } p_t;
module dut(input logic [7:0] v, input p_t p);
  mod m(.a(v[p.idx[2:0]]));
endmodule
