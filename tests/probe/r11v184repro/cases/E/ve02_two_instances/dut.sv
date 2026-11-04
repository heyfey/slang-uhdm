// § genLocalEnumConstShared184: two identical instances of a module whose generate block declares its own enum
module sub #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {A0, A1, A2} a_e;
    a_e q;
    always_ff @(posedge clk)
      case (q)
        A0: q <= A1;
        A1: q <= A2;
        default: q <= A0;
      endcase
    always_comb y = (q == A2) ? 2'd1 : 2'd2;
  end
endmodule
module top(input logic clk, output logic [1:0] y0, y1);
  sub u0 (.clk(clk), .y(y0));
  sub u1 (.clk(clk), .y(y1));
endmodule
