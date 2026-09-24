// § defNetTypeParamDefault137
// case tp04: a type parameter whose default depends on a value parameter
module sub #(parameter int W = 5, parameter type T = logic [W-1:0]) (output logic [4:0] o);
  T v;
  assign v = '1;
  assign o = v;
endmodule
module top(output logic [4:0] o); sub u(.o(o)); endmodule
