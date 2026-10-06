// § castStructInstCopy260 (the cast in an always_comb, Earlgrey's shape)
module m (input logic [31:0] w, input logic we, output logic [5:0] o);
  typedef struct packed {
    logic [25:0] unused_ctrl;
    logic [5:0]  x;
  } t_t;
  t_t cpuctrl_q, cpuctrl_d, cpuctrl_wdata;
  assign cpuctrl_wdata = t_t'(w);
  always_comb begin
    cpuctrl_d = cpuctrl_q;
    if (we) cpuctrl_d = cpuctrl_wdata;
    cpuctrl_d.unused_ctrl = '0;
  end
  assign o = cpuctrl_d.x;
endmodule
module top;
  logic [31:0] w; logic we; logic [5:0] o;
  m u (.w(w), .we(we), .o(o));
endmodule
