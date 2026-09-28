// § elabIfArrIdxChainName205 — r11u217 a03: a CONCATENATION left side over two interface-array element members (v11u210 F2), a member bit-select and part-select target `b[i].v[0]`, `b[i].v[3:2]`, with literal right sides
interface bi;
  logic w;
  logic x;
  logic [3:0] v;
endinterface
module dut(output logic o, output logic [3:0] q);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign {b[i].w, b[i].x} = 2'b10;
    assign b[i].v[0] = 1'b1;
    assign b[i].v[1] = 1'b0;
    assign b[i].v[3:2] = 2'b01;
  end
  assign o = b[1].x;
  assign q = b[0].v;
endmodule
