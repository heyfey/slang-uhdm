// § modEnumTfArgCloneFollows299
interface ifc (input logic [1:0] d);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  function automatic logic f(input b_e q); return q == BA; endfunction
  logic o;
  assign o = f(b_e'(d)) ^ (LP == BC);
endinterface
module top (input logic [1:0] d, output logic o);
  ifc i (d);
  assign o = i.o;
endmodule
