// § portViewParamDefName130
interface cfg #(parameter int N = 2);
  logic [N-1:0] v;
endinterface
interface bus (cfg c);
  logic d;
endinterface
module top;
  cfg #(.N(5)) c0();
  bus b0(.c(c0));
endmodule
