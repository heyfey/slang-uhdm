interface bif #(parameter int W = 16);
  localparam int BYT = W/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf (bif.mp q, output logic o); assign o = q.d[0]; endmodule

module top (output logic [3:0] o);
  bif #(.W(32)) arr [2] ();
  leaf g0 (.q(arr[0].mp), .o(o[0]));
  leaf g1 (.q(arr[1].mp), .o(o[1]));
  genvar gi;
  for (gi = 0; gi < 2; gi++) begin : gb
    leaf gx (.q(arr[gi].mp), .o(o[2+gi]));
  end
endmodule
