// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [1:0] sd, output logic o);
  localparam D = 2;
  always_comb begin
    if (sd[D-1].v) o = 1'b1;
    else o = 1'b0;
  end
endmodule
