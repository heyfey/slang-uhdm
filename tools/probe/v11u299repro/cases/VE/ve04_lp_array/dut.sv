// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LPA [2] = '{BB, BC};
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LPA[0] == BC);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
