// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  function automatic logic [15:0] f(input logic [31:0] x); return x[31:16]; endfunction
  assign o = f(d) ^ d[15:0];
endmodule
module mid (input logic [31:0] d, output logic [15:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    leaf l (.d(d), .o(o));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
