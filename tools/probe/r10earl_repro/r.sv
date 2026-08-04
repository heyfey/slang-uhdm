package sp;
  parameter ArbiterImpl = "PPC";
  parameter string Named = "QQQ";
  parameter int    W     = 4;
endpackage

module sm import sp::*; #(
  parameter int RegAw = 8
) (
  input clk_i
);
endmodule
