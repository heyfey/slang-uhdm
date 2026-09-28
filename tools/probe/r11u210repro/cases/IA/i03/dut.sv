// § elabIfArrIdxChainName205 — i03: controls, right sides that read (a reference, a select, an operation, a genvar) beside a literal one
interface bi;
  logic w;
endinterface
module dut(input logic [3:0] x, output logic o);
  bi b[4]();
  for (genvar i = 0; i < 4; i++) begin : g
    if (i == 0) begin : a
      assign b[i].w = x[0];
    end else if (i == 1) begin : bb
      assign b[i].w = x[1] & x[2];
    end else if (i == 2) begin : cc
      assign b[i].w = i[0];
    end else begin : dd
      assign b[i].w = 1'b1;
    end
  end
  assign o = b[1].w;
endmodule
