// § unpStructArrElemVar412
typedef struct { logic [3:0] a; logic b; } ms_t;
interface ifc;
  ms_t ia[2];
endinterface
module top(output logic [3:0] o);
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    ms_t ga[2];
    assign ga[0].a = g;
  end
  ms_t m[1:0] = '{'{4'd1, 1'b0}, '{4'd2, 1'b1}};
  assign o = m[1].a;
endmodule
