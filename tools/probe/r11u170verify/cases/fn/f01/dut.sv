// § fnParamRangeNetNoFile163
module shift (input logic [7:0] a, output logic [7:0] o, output logic [7:0] o2);
  function automatic logic [7:0] f(input logic [7:0] x);
    parameter len = 4;
    reg [len-1:0] lo;
    reg [len-1:0] hi;
    lo = x[len-1:0]; hi = x[7:len];
    return {lo, hi};
  endfunction
  assign o = f(a);
  assign o2 = f(~a);
endmodule
module top (input logic [7:0] a, output logic [7:0] o, output logic [7:0] o2); shift s(.a(a), .o(o), .o2(o2)); endmodule
