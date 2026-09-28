// § propAssertLastInstPath188
module chk #(parameter int W = 1) (input logic clk, input logic a, input logic rst);
  logic q;
  assign q = a;
  property p_a;
    @(posedge clk) disable iff (rst) q |-> ##W !a;
  endproperty
  a_p: assert property (p_a) else $error("bad %0d", W);
endmodule
module mid(input logic clk, input logic a, input logic rst);
  chk #(.W(2)) u_c(.clk(clk), .a(a), .rst(rst));
endmodule
module tb;
  logic clk, a, rst;
  mid u_m(.clk(clk), .a(a), .rst(rst));
endmodule
