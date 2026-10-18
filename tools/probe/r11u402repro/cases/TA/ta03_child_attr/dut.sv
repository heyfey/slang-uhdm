// § topModSpanSkipsAttrs402
(* blackbox *)
module sub(input a); endmodule
module top(input x); sub s(.a(x)); endmodule
