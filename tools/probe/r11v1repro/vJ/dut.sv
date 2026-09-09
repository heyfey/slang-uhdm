interface bif #(parameter int W = 16);
  localparam int BYT = W/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module inner_mp (bif.mp s, output logic o); assign o = s.d[0]; endmodule
module inner_pl (bif    s, output logic o); assign o = s.d[0]; endmodule

module mid_mp (bif.mp q, output logic [1:0] o);
  inner_mp i0 (.s(q),   .o(o[0]));
  inner_pl i1 (.s(q),   .o(o[1]));
endmodule

module mid_pl (bif q, output logic [1:0] o);
  inner_mp i0 (.s(q.mp), .o(o[0]));
  inner_pl i1 (.s(q),    .o(o[1]));
endmodule

module top (output logic [3:0] o);
  bif #(.W(32)) u ();
  mid_mp m0 (.q(u.mp), .o(o[1:0]));
  mid_pl m1 (.q(u),    .o(o[3:2]));
endmodule
