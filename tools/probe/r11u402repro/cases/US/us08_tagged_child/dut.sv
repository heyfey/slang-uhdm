// § unpackedTaggedElabSpan402
module sub();
union tagged { void n; int v; } u;
endmodule
module top(); sub s(); endmodule
