// § caLvTrailIdxNamesByPath264
package pk;
  typedef struct packed { logic [3:0] en; } s_t;
endpackage
module leaf (input logic [3:0] a, output pk::s_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
endmodule
module mid (input logic [3:0] a, output pk::s_t w);
  leaf l(.a(a), .w(w));
endmodule
module top(input logic [3:0] a, output pk::s_t w);
  mid m(.a(a), .w(w));
endmodule
