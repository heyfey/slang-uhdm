// § castStructInstCopy260 (the typedef declared in an if-generate block, the cast there)
module m #(parameter bit E = 1) (input logic [7:0] w, output logic [3:0] o);
  if (E) begin : g
    typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
    t_t r;
    assign r = t_t'(w);
    assign o = r.a;
  end else begin : h
    assign o = '0;
  end
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
