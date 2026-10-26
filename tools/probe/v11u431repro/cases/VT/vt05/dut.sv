// § bodyTypeParamDefKeepsDecl431 (a program)
program prg();
parameter type T = int;
T v;
endprogram
module top();
prg #(.T(byte)) p ();
endmodule
