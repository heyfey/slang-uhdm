// § bitsConcatLastResolvesAbstain421v
module c #(parameter w_p = 4) (input logic [3:0] a, input logic [w_p-1:0] b, output logic [7:0] o);
  localparam W = $bits({a, b});
  assign o = W;
endmodule
module top (input logic [3:0] a, b, output logic [7:0] o1, o2); c #(.w_p(4)) u(a, b, o1); c #(.w_p(2)) v(b, a[1:0], o2); endmodule
