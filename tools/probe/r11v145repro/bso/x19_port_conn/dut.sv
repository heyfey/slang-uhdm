// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module c(input logic x, output logic y);
  assign y = x;
endmodule
module dut(input s_t [3:0] sd, output logic o);
  localparam D = 3;
  c u(.x(sd[D-1].v), .y(o));
endmodule
