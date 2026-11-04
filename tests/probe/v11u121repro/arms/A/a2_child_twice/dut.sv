module sub #(parameter type T = logic [1:0]) (input logic s, input logic [3:0] v, output logic [7:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = s ? T'({v[i], v[i+1]}) : T'(v[i+2]);
  end
endmodule
module top (input logic s, input logic [3:0] v, output logic [7:0] a [2], output logic [7:0] b [2]);
  sub #(.T(logic [2:0])) u0 (.s(s), .v(v), .y(a));
  sub u1 (.s(s), .v(v), .y(b));
endmodule
