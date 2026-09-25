// § hpBaseSelOpIdxNamesByPath145 (control: a bare base index)
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, input logic i, output s_t o);
  s_t [1:0] sd;
  always_comb begin
    sd = '0;
    sd[i].v = p;
  end
  assign o = sd[0];
endmodule
