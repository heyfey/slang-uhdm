// § classKwParamsLast412
class c1 #(parameter int a = 1, type T = int);
endclass
class c2 #(int a = 1, parameter b = 2, type T = int, int c = 3);
endclass
class c3 #(type T = int, parameter w = 1, type U = int);
endclass
class c4 #(parameter w = 1, parameter type T = int);
endclass
class c5 #(localparam w = 1, type T = int);
endclass
module top; endmodule
