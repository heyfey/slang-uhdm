// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LP == BC);
endmodule
module top (input logic [1:0] d, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : gg
    m u (.d(d), .o(o[k]));
  end
endmodule
