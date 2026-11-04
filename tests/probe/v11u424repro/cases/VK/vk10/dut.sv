// § boundSizedLitKept424
package pk; typedef logic [4'd7:0] byte_t; endpackage
module sub(input pk::byte_t a); endmodule
module top; pk::byte_t x; sub s(x); endmodule
