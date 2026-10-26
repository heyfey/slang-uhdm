// § bodyTypeParamDefKeepsDecl431 (a body type parameter beside a value parameter)
module sub();
parameter W = 4;
parameter type T = logic [W-1:0];
T v;
endmodule
module top();
sub #(.W(8), .T(int)) s1 ();
endmodule
