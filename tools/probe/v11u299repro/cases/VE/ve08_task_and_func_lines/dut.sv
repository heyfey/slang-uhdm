// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB,
                 LQ = BC;
  function automatic logic f(input b_e q); return q == BA; endfunction
  task automatic t(input b_e q, output logic z); z = (q == BB); endtask
  assign o = f(b_e'(d)) ^ (LP == BC) ^ (LQ == BA);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
