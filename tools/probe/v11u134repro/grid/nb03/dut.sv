// § elabNetTdCloneNoAlias134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef logic [3:0] v_t;
  wire v_t a [2];
  wire v_t b = 4'h3;
  assign a[0] = i;
  assign a[1] = i;
  assign o = a[0] ^ a[1] ^ b;
endmodule
