// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [1:0] sd, input logic [15:0] i, output logic [15:0] o);
  localparam D = 2;
  always_comb o = i[$bits(sd[D-1].r):0];
endmodule
