// § hpTrailIpsNamesByPath218
typedef struct packed { logic [31:0] a_data; logic v; } tl_t;
module top #(parameter int OFF = 4) (input tl_t tl, input logic [4:0] i, output logic [7:0] o, output logic [7:0] q);
  assign o = tl.a_data[i +: 8];
  assign q = tl.a_data[OFF -: 5];
endmodule
