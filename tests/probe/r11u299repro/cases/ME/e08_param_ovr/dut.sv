// § modEnumTfArgCloneFollows299
module m #(parameter int W = 4) (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LP == BC) ^ (W > 4);
endmodule
module top (input logic [1:0] d, output logic o);
  m #(.W(8)) u (.d(d), .o(o));
endmodule
