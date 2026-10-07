// § leftoverTsCopyPerElabUse272
// a $unit struct parameter built by a $unit function (not a package parameter: no value copy)
typedef struct packed { int unsigned a; int unsigned b; } uin_t;
typedef struct packed { uin_t u; int unsigned d; } uc_t;
localparam uin_t UUU = '{a: 11, b: 22};
function automatic uc_t umk();
  uc_t c; c.u = UUU; c.d = 64; return c;
endfunction
localparam uc_t UC = umk();
module kid #(parameter uc_t P = UC) (output logic o);
  localparam int unsigned RD = P.d;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
