// § arrQueryParamArgOnly158v
module top(input logic [5:2] a, output logic [5:2] b);
  parameter high = $high(a);
  assign b = a;
endmodule
