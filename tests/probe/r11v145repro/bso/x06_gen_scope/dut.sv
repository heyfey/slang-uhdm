// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, output logic o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sd[i+1].v;
  end
endmodule
