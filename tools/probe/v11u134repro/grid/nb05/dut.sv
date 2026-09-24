// § elabNetTdCloneNoAlias134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef logic [3:0] v_t;
  wire v_t a, b;
  wand v_t c;
  assign a = i;
  assign b = ~i;
  assign c = a;
  assign o = b ^ c;
endmodule
