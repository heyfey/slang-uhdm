// § elabIfArrIdxChainName205 — va05 (v11u210 break probe): a genvar-indexed interface-array target whose literal right side sits in parentheses twice, one inside a named if-generate inside a for-generate, beside a target driven by a parameter (not a literal)
interface bi;
  logic [3:0] v;
endinterface
module dut(output logic [3:0] o);
  localparam logic [3:0] PV = 4'd9;
  bi b[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : z
      assign b[i].v = ((4'd2));
    end else begin : nz
      assign b[i].v = PV;
    end
  end
  for (genvar j = 2; j < 4; j++) begin : h
    assign b[j].v = 'x;
  end
  assign o = b[1].v ^ b[3].v ^ b[0].v;
endmodule
