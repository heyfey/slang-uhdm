// § elabIfArrIdxChainName205 — va04 (v11u210 break probe): literal forms at the edge of the gate (x/z literals, '0, a negative literal, a cast of a literal) and a two-level if-in-case generate with a genvar index
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut #(parameter int K = 0) (output logic [3:0] o);
  bi b[6]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = 1'bz;
    assign b[i].v = '0;
  end
  for (genvar j = 2; j < 4; j++) begin : h
    case (K)
      0: begin : c
        if (j > 2) begin : e
          assign b[j].v = -1;
        end else begin : f
          assign b[j].v = 4'bx01x;
        end
      end
    endcase
  end
  for (genvar m = 4; m < 6; m++) begin : r
    assign b[m].v = 4'(3);
  end
  assign o = b[2].v ^ b[5].v;
endmodule
