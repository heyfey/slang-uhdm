// § arrQueryParamArgOnly158v
module top();
  parameter [7:0] m [0:3] = '{0, 1, 2, 3};
  parameter high = $high(m);
  parameter low = $low(m);
endmodule
