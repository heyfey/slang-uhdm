interface bif #(parameter int W = 16);
  localparam int BYT = W/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf_mp (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module leaf_pl (bif    q, output logic o); assign o = q.d[0]; endmodule

module holder (output logic [1:0] o);
  // the actual lives inside a generate block, invisible from the instantiating
  // scope of the two children below by a plain lexical find
  if (1) begin : gb
    bif #(.W(32)) inner ();
  end
  leaf_mp c0 (.q(gb.inner.mp), .o(o[0]));
  leaf_pl c1 (.q(gb.inner),    .o(o[1]));
endmodule

module top (output logic [1:0] o);
  holder h0 (.o(o));
endmodule
