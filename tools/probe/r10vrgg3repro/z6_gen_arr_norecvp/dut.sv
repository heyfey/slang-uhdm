interface itfg #(parameter int AW = 16, parameter int BW = 32,
                 parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  if (1) begin : g
    logic gsig;
  end
  modport mp (input a, b, v);
endinterface
module recv (itfg.mp p[3]);
endmodule
module top;
  itfg #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
