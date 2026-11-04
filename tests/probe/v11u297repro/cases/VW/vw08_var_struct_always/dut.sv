// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(input logic clk, output logic [2:0] o);
  var t_t x = 3'b001;
  always_ff @(posedge clk) x <= {x.a + 2'd1, ~x.b};
  assign o = x;
endmodule
