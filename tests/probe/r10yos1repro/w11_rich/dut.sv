typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;

module \a.b.C (input wire clk, input wire [7:0] din, output logic [7:0] dout);
  pair_t p;
  logic [7:0] r;
  wire [7:0] w = din;
  assign p = w;
  always_ff @(posedge clk) r <= {p.b, p.a};
  assign dout = r;
endmodule
