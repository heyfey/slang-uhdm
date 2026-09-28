// § elabIfArrIdxChainName205 — va07 (v11u210 break probe): literal-driven targets with a SELECT on the interface-array element's leaf (bit and part select) and a NESTED interface instance inside the array element
interface ci;
  logic z;
endinterface
interface bi;
  logic [3:0] v;
  ci c();
endinterface
module dut(output logic [3:0] o, output logic p);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].v[0] = 1'b1;
    assign b[i].v[3:1] = 3'b010;
    assign b[i].c.z = 1'b0;
  end
  assign o = b[1].v;
  assign p = b[0].c.z;
endmodule
