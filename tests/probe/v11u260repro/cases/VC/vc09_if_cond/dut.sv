// § castStructInstCopy260 (the cast in an if condition and a case expression)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t k;
  assign k = 8'h31;
  always_comb begin
    o = '0;
    if (t_t'(w) == k) o = 4'd1;
    case (t_t'(w))
      8'h22: o = 4'd2;
      default: ;
    endcase
  end
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
