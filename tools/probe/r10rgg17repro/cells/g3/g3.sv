// r10rgg17 grid g3 — the SCOPE axis: the genvar the index reads is declared in
// the SAME block, in an OUTER block, or in both (the corpus head's shape), plus
// the NON-CONNECTION control: the identical select written in a gen-scope
// CONT-ASSIGN, which r10rgg14 measured golden does NOT fold.
interface sif;
  logic [31:0] value;
endinterface

module sink (input logic [3:0] d);
endmodule

module top;
  sif arr[20]();
  logic [3:0] w1, w2, w3;

  for (genvar i = 0; i < 2; i++) begin : go
    // the genvar is the OUTER block's own
    sink u_c1 (.d(arr[6+7*i].value[0+:4]));
    if (1) begin : gif
      for (genvar l = 0; l < 2; l++) begin : g
        // BOTH: an outer genvar in the element index, an inner one in the base
        sink u_c2 (.d(arr[6+7*i+6].value[0+1*l+:1]));
        // inner genvar in the element index too
        sink u_c3 (.d(arr[2*i+l].value[0+:4]));
      end
    end
    // THE CONTROL: the same shape in a gen-scope CONT-ASSIGN, not a port
    // connection.  Golden keeps it symbolic (r10rgg14 § 3).
    assign w1 = arr[6+7*i].value[0+:4];
  end
  assign w2 = arr[3].value[0+:4];
  assign w3 = arr[4].value[3:0];
endmodule
