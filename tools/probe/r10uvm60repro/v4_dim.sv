// VERIFIER ARM v4 — the PACKED-DIMENSION RANGE cell, ISOLATED.
// A packed dimension bound is an elaboration-time constant expression; Surelog
// reduces it, runs the called body, and stamps the constant actual inside that
// body.  The landed two-seed closure does not contain this reach.
module v4_dim(input logic [3:0] inp, output logic [3:0] o);
   function automatic logic [3:0] g60(logic [3:0] v);
      return v;
   endfunction
   function automatic logic [3:0] w3(logic [3:0] x);
      return x + g60(1);
   endfunction
   logic [w3(4'd1):0] v3;
   assign o = {2'b0, v3};
endmodule
