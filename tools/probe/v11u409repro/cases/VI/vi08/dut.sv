// § modImpTdParamTsClone409
interface ifc;
  typedef bit [1:0] t_t;
  parameter t_t K = 2'd1;
  logic [1:0] s;
  assign s = K;
endinterface
module top;
  ifc i();
endmodule
