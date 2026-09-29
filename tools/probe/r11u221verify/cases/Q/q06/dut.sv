// § genScopeRangeQueryFold216 — queries at depths 1-3: gen-for > gen-if > gen-case, on a module net, a port and a parameter
module dut #(parameter logic [11:4] P = 0, parameter int M = 2) (input logic [0:6] i, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  logic [13:5] net;
  for (genvar a = 0; a < 2; a++) begin : l1
    if (a == 1) begin : l2
      case (M)
        2: begin : l3
          assign o1 = $high(net);
          assign o2 = $low(i);
          assign o3 = $left(P);
        end
        default: begin : l3d end
      endcase
    end
  end
endmodule
