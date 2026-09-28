// § propAssertLastInstPath188
module sub(input logic a, output logic x);
  assign x = a;
endmodule
module chk(input logic clk, input logic a);
  logic x;
  sub u_sub(.a(a), .x(x));
  function automatic logic inv(logic v); return !v; endfunction
  property p_a;
    @(posedge clk) u_sub.x |-> ##1 inv(a);
  endproperty
  a_p: assert property (p_a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule
