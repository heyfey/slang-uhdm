// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  typedef b_e b2_e;
  localparam b2_e LP = BB;
  localparam b_e LQ = BC;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LP == BC) ^ (LQ == BA);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
