// § caLvTrailIdxNamesByPath264
interface ifc(input logic [3:0] a);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  ifc i(a);
  assign o = i.w.en;
endmodule
