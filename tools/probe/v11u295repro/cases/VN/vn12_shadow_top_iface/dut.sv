// § nestArrShadowTopKeepsBare295v
interface inner; logic d; endinterface
module outer(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  outer u_o (.a(a), .b(b));
endmodule
