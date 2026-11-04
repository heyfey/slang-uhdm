// § bodyTypeParamDefKeepsDecl431 (a header parameter list with a body type localparam-ized parameter)
module sub #(parameter W = 2) ();
parameter type T = logic [W-1:0];
T v;
endmodule
module top();
sub #(.W(5)) s1 ();
endmodule
