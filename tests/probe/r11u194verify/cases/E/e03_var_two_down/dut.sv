// § genLocalEnumConstShared184: an enum and its variable declared in an outer generate block; a process two generate blocks down reads the constants (no variable there)
module top (input logic clk, input logic a, output logic y);
  if (1) begin : g0
    typedef enum logic [1:0] {S0, S1, S2} st_e;
    st_e q;
    if (1) begin : g1
      if (1) begin : g2
        always_ff @(posedge clk) begin
          if (a) q <= S1;
          else if (q == S1) q <= S2;
          else q <= S0;
        end
      end
    end
    assign y = (q == S2);
  end
endmodule
