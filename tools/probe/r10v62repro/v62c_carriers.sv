// v62c — every CARRIER for a module-local typedef reference in a module with
// three specializations: net decl-init, var decl-init, procedural assign,
// port actual, function return, task arg, unpacked array, net of the type.
module cc62 #(parameter int W = 4) (
  input  logic          clk,
  input  logic [W-1:0]  din,
  output logic [W-1:0]  dout,
  output logic [3:0]    st
);
  typedef enum logic [1:0] { RA, RB, RC } r_op_e;
  typedef struct packed { r_op_e op; logic [1:0] sz; } r_t;

  r_t        rv;
  r_t        rarr [0:2];          // unpacked array of the typedef
  wire r_t   rnet;                // NET of the typedef
  r_t        rinit = '{ op: RB, sz: 2'b01 };   // decl-init
  logic      ff;

  assign rnet = '{ op: RC, sz: 2'b10 };        // net decl carrier
  always_comb ff = (rv.op == RA) | (rarr[1].op == RB);   // procedural
  function automatic logic is_b(input r_t q); return q.op == RB; endfunction
  assign st = { ff, is_b(rinit), (rnet.op == RC), (rarr[0].sz == 2'b11) };
  assign dout = { {(W-2){1'b0}}, rv.sz };
endmodule

module top62c2 (input logic clk, output logic [15:0] o);
  logic [3:0] d4, s4; logic [7:0] d8, junk8; logic [3:0] s4b, s4c; logic [15:0] d16;
  cc62 #(.W(4))  u_a (.clk(clk), .din(4'h0),  .dout(d4),  .st(s4));
  cc62 #(.W(8))  u_b (.clk(clk), .din(8'h0),  .dout(d8),  .st(s4b));
  cc62 #(.W(16)) u_c (.clk(clk), .din(16'h0), .dout(d16), .st(s4c));
  assign o = d16 ^ {8'b0, d8} ^ {12'b0, d4} ^ {4'b0, s4, s4b, s4c};
endmodule
