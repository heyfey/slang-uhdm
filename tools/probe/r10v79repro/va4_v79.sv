// r10v79 adversarial arm 4 — instance-array dims and typedef'd unpacked arrays
// with expression bounds, plus a struct/enum element type.
module leafv4 (input logic a, output logic b);
  assign b = a;
endmodule
module sinkv4 #(parameter int unsigned N = 4) (input logic clk);
  typedef logic [7:0] tv4_p [N+1];
  typedef logic [7:0] tv4_m [N*2];
  typedef logic [7:0] tv4_b [N];
  tv4_p td_p;
  tv4_m td_m;
  tv4_b td_b;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } sv4_t;
  sv4_t st_p [N+1];
  sv4_t st_b [N];
  typedef enum logic [1:0] { E0, E1 } ev4_t;
  ev4_t en_p [N*2];
  logic la [N+1];
  leafv4 u_iap [N+1] (.a(la[0]), .b());
  leafv4 u_iab [N]   (.a(la[0]), .b());
  for (genvar gi = 0; gi < 2; gi++) begin : gv4
    leafv4 u_g [N+1] (.a(la[0]), .b());
  end
endmodule
module topv4;
  logic clk;
  sinkv4 #(.N(3)) u_a (.clk(clk));
  sinkv4 #(.N(5)) u_b (.clk(clk));
  sinkv4 #(.N(4)) u_c (.clk(clk));
endmodule
