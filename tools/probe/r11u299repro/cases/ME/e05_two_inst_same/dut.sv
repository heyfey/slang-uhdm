// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LP == BC);
endmodule
module top (input logic [1:0] d, output logic [1:0] o);
  m u0 (.d(d), .o(o[0]));
  m u1 (.d(d), .o(o[1]));
endmodule
