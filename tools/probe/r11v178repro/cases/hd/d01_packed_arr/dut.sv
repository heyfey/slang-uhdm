// § hierPathSelIdxAtPath178
module top(input logic [1:0] i, input logic [15:0] din, output logic [3:0] y, output logic [3:0] z);
  typedef struct packed { logic [3:0] v; } s_t;
  s_t [3:0] a;
  assign a = din;
  assign y = a[i+1].v;
  assign z = a[i].v;
endmodule
