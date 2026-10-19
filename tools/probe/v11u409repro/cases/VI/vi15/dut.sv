// § modImpTdParamTsClone409
typedef bit [3:0] u_t;
module sub #(parameter u_t N = 4'd2) (output [3:0] o);
  assign o = N;
endmodule
module top (output [3:0] o);
  sub #(.N(4'd5)) u (.o(o));
endmodule
