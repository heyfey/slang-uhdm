// § typeParamStructAtKeyword146
module m #(parameter type T = struct
  packed {
    logic a;
  }) (input T i, output T o);
  assign o = i;
endmodule
module top(input i, output o); m u(.i(i), .o(o)); endmodule
