// § implicitArgDimsInner155
module top(); function automatic logic f(output [2:0] y, [1:0] z); y = 0; return z[0]; endfunction endmodule
