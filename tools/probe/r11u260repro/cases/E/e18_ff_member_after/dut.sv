// § castStructInstCopy260 (an always_ff cast then a member write)
module m (input logic c, input logic [31:0] w, output logic [5:0] o);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  t_t q;
  always_ff @(posedge c) begin
    q <= t_t'(w);
    q.a <= '0;
  end
  assign o = q.x;
endmodule
module top;
  logic c; logic [31:0] w; logic [5:0] o;
  m u (.c(c), .w(w), .o(o));
endmodule
