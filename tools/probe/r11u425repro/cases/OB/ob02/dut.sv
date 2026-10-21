// § oneTickUpperBNormalized425
module top #(parameter P = 1'B1, parameter Q = 1'B0, parameter R = 1'BX)(input a, output o);
  assign o = a & P & Q & R;
endmodule
