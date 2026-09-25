// § fnParamRangeNetNoFile163
module shift #(parameter int N = 2) (input logic [7:0] a, output logic [7:0] o [N]);
  function automatic logic [7:0] f(input logic [7:0] x);
    localparam len = 3;
    reg [len-1:0] lo;
    lo = x[len-1:0];
    return {x[7:len], lo};
  endfunction
  for (genvar g = 0; g < N; g++) begin : G
    assign o[g] = f(a ^ 8'(g));
  end
endmodule
module top (input logic [7:0] a, output logic [7:0] o [2]); shift s(.a(a), .o(o)); endmodule
