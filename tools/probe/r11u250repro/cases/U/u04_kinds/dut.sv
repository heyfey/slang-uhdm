// § modParamKwTdCopy250
typedef byte ub_t;
typedef integer ug_t;
typedef shortint us_t;
typedef longint unsigned ul_t;
typedef bit ux_t;
module top;
  parameter ub_t A = 1;
  parameter ug_t B = 2;
  localparam us_t C = 3;
  localparam ul_t D = 4;
  parameter ux_t E = 1;
  int v;
  assign v = A + B + C + D + E;
endmodule
