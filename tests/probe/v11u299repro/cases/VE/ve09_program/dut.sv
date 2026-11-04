// § modEnumTfArgCloneFollows299
program prg (input logic [1:0] d);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  function automatic logic f(input b_e q); return q == BA; endfunction
  logic o;
  initial o = f(b_e'(d)) ^ (LP == BC);
endprogram
module top (input logic [1:0] d);
  prg p (d);
endmodule
