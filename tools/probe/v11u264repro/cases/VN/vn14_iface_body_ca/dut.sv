// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } s_t;
interface ifc(input logic [3:0] a);
  s_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  ifc i(.a(a));
  assign o = i.w.en;
endmodule
