// § castStructInstCopy260 (the cast in an initial block and in a unique-case item of an always_comb, a member write after)
module m (input logic [7:0] w, input logic [1:0] s, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r, z;
  initial z = t_t'(8'h5a);
  always_comb begin
    unique case (s)
      2'd0: r = t_t'(w);
      default: r = z;
    endcase
    r.b = '0;
  end
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [1:0] s; logic [3:0] o;
  m u (.w(w), .s(s), .o(o));
endmodule
