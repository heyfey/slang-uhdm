// § octUnszElabRespell423
module sub(output int y);
  parameter O = 'o12;
  initial y = O;
endmodule
module top(output int y);
  sub u(.y(y));
endmodule
