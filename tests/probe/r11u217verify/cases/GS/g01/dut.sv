// § genConnTrailSelChain205 — r11u217 g01: a modport interface PORT's member bit-select connected in a for-generate (named port) and positionally in a nested for-generate with genvar arithmetic
interface bi;
  logic [7:0] d;
  logic [7:0] e;
  modport m (input d, input e);
endinterface
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module mid (bi.m b, output logic [7:0] o, output logic [3:0] q);
  for (genvar k = 0; k < 8; k++) begin : gl
    leaf u (.x(b.d[k]), .y(o[k]));
  end
  for (genvar i = 0; i < 2; i++) begin : go
    for (genvar j = 0; j < 2; j++) begin : gi
      leaf v (b.e[2*i+j], q[i*2+j]);
    end
  end
endmodule
module top (input logic [7:0] a, input logic [7:0] c, output logic [7:0] o, output logic [3:0] q);
  bi s();
  assign s.d = a;
  assign s.e = c;
  mid m0 (.b(s.m), .o(o), .q(q));
endmodule
