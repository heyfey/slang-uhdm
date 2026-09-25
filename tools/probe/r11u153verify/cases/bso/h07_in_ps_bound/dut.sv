// § hpBaseSelOpIdxNamesByPath145 law psRangeBoundHpBaseSelKeeps153v
typedef struct packed { logic [7:0] w; } s_t;
module dut(input logic [7:0] i, output logic [7:0] o);
  localparam int D = 2;
  localparam s_t [1:0] P = '{'{w: 8'd4}, '{w: 8'd6}};
  assign o = i[P[D-1].w-1:0];
endmodule
