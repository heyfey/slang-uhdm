// § escBlockNameSpanTrailSpace286 — escaped block in a generate process, a named fork, two escaped names on one line
module top(input logic [3:0] d, output logic [3:0] r, output logic [3:0] q);
  for (genvar i = 0; i < 1; i++) begin : g
    always_comb begin : \gb@1 
      r = d;
    end
  end
  initial fork : \fk@1 
  join
  always_comb begin : \a@1  q = d; begin : \b@2  end end
endmodule
