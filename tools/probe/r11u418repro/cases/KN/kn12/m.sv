// § tdKeptParentMemberNames418
import tp::tag_s;
module m #(parameter N = 2) (input tag_s ti, output [N-1:0] o);
  for (genvar i = 0; i < N; i++) begin : g
    tag_s h;
    assign o[i] = h.param;
  end
endmodule
