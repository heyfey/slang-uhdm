// § netKindTypeAll402
module sub(input x); tri1 t; assign t = x; endmodule
module top(input a); sub s(.x(a)); endmodule
