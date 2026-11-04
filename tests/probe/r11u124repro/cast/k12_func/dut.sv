// § castTsFile124
module top(input logic [7:0] a, output logic [3:0] o); function automatic logic [3:0] f(logic [7:0] x); return 4'(x); endfunction assign o = f(a); endmodule
