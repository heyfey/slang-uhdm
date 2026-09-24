package pk;
  parameter int PW = 4;
endpackage

interface eif #(parameter int W = 5);
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf #(parameter int W = 3) (output logic [W-1:0] z); assign z = '0; endmodule

program prg (eif.mp p, output logic o);
  assign o = p.d[0];
endprogram

module top (output logic [2:0] o);
  eif #(.W(9)) u ();
  leaf #(.W(6)) l0 (.z());
  prg  p0 (.p(u.mp), .o(o[0]));
  eif  ud ();
  assign o[1] = ud.d[0];
  assign o[2] = 1'b0;
endmodule
