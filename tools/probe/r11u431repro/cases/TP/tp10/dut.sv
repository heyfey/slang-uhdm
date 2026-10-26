// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type a_t = int;
parameter type b_t = a_t;
a_t va; b_t vb;
endmodule
module top();
sub #(.a_t(byte), .b_t(shortint)) s1 ();
endmodule
