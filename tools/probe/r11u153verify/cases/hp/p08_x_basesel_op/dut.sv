// § constPathBaseAnyKind146 § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [1:0] sd, output logic [3:0] o);
  localparam D = 2;
  logic [$bits(sd[D-1].r)-1:0] x;
  assign x = sd[D-1].r;
  assign o = x;
endmodule
