// § ndaSysCallNetTs212 — verifier: a net of a logic-vector typedef initialized by a signing cast
typedef logic [6:0] v_t;
module dut (input logic [9:0] i, output logic [6:0] o);
  wire v_t w = signed'(i[6:0]);
  assign o = w;
endmodule
