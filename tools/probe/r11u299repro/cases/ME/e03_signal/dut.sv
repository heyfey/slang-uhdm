// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  b_e s;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign s = b_e'(d);
  assign o = f(s);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
