// § escBlockNameSpanTrailSpace286 — escaped names on always_comb and initial named blocks, a plain control
module top(input logic [3:0] d, output logic [3:0] r, output logic [3:0] q);
  always_comb begin : \blk@1 
    r = d;
  end
  always_comb begin : \x 
    q = d;
  end
  initial begin : \longer_name$2 
  end
  initial begin : plain
  end
endmodule
