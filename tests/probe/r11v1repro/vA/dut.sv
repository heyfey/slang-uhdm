interface bif #(parameter int W = 16);
  localparam int BYT = W/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module mp_named (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module pl_named (bif     q, output logic o); assign o = q.d[0]; endmodule
module pl_pos   (bif     q, output logic o); assign o = q.d[0]; endmodule
module mp_pos   (bif.mp  q, output logic o); assign o = q.d[0]; endmodule

module top (output logic [3:0] o);
  bif #(.W(32)) u ();
  mp_named a0 (.q(u.mp), .o(o[0]));
  pl_named a1 (.q(u),    .o(o[1]));
  pl_pos   a2 (u, o[2]);
  mp_pos   a3 (u.mp, o[3]);
endmodule
