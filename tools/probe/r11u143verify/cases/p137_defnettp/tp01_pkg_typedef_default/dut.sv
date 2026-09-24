// § defNetTypeParamDefault137
// case tp01: a type parameter defaulting to a package struct typedef, one net
package tpp; typedef struct packed { logic [2:0] a; logic b; } s_t; endpackage
module sub #(parameter type T = tpp::s_t) (output logic [3:0] o);
  T d;
  assign d = 4'hB;
  assign o = d;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
