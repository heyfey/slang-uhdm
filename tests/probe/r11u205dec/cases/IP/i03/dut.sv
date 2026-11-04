// r11u205 IP i03: a struct-variable member indexed part select as a for-generate target
typedef struct packed { logic [7:0] a; logic [3:0] b; } s_t;
module dut(input logic [1:0] x, output s_t o);
  s_t w;
  for (genvar k = 0; k < 1; k++) begin : g
    assign w.a[2+:2] = x;
  end
  assign o = w;
endmodule
