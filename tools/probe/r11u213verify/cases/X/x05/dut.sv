// § genScopeClassVarSpecAtName206 § bitSelMethodCallIdxSpan207 (a generate-scope specialization variable whose method call indexes a select)
class c #(int W = 4);
  function int get(int i); return i % W; endfunction
endclass
module x05 (input logic [7:0] a, input int k, output logic y);
  if (1) begin : g
    c #(3) q;
    initial begin
      q = new;
      y = a[q.get(k)];
    end
  end
endmodule
