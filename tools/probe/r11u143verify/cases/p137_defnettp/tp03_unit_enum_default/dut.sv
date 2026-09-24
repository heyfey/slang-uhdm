// § defNetTypeParamDefault137
// case tp03: a type parameter defaulting to a $unit enum typedef
typedef enum logic [1:0] {E0, E1, E2} ue_t;
module sub #(parameter type T = ue_t) (output logic [1:0] o);
  T s;
  assign s = E1;
  assign o = s;
endmodule
module top(output logic [1:0] o); sub u(.o(o)); endmodule
