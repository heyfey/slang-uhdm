// § defNetTypeParamDefault137
// case tp05: a definition net typed by a type parameter with an added packed dimension
module sub #(parameter type T = logic) (output logic [3:0] o);
  T [3:0] v;
  assign v = 4'h6;
  assign o = v;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
