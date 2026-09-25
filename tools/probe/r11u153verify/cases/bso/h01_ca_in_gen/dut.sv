// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [1:0] sd, output logic o);
  localparam D = 2;
  if (1) begin : g
    assign o = sd[D-1].v;
  end
endmodule
