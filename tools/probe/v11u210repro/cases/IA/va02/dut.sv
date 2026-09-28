// § elabIfArrIdxChainName205 — va02 (v11u210 break probe): a PARAMETER (not a genvar) as the interface-array index of a literal-driven target in if- and case-generate scopes
interface bi;
  logic w;
  logic x;
endinterface
module dut #(parameter int M = 1) (output logic o, output logic p);
  localparam int P = 1;
  bi b[4]();
  if (M == 1) begin : g
    assign b[P].w = 1'b1;
    assign b[M].x = 1'b0;
  end
  case (M)
    1: begin : c
      assign b[P+1].w = 1'b0;
    end
    default: begin : d
      assign b[0].w = 1'b0;
    end
  endcase
  assign o = b[1].w;
  assign p = b[2].w;
endmodule
