// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } s_t;
module sub #(parameter int M = 1) (input logic [3:0] a, output s_t w);
  if (M == 1) begin : gi
    for (genvar k = 0; k < 2; k++) begin : g
      assign w.en[k] = a[k];
    end
  end else begin : ge
    assign w.en[1:0] = '0;
  end
  case (M)
    1: begin : c1
      for (genvar j = 2; j < 4; j++) begin : h
        assign w.en[j] = a[j];
      end
    end
    default: begin : cd
      assign w.en[3:2] = '0;
    end
  endcase
endmodule
module top(input logic [3:0] a, output s_t w, output s_t v);
  sub u(.a(a), .w(w));
  sub #(.M(2)) u2(.a(a), .w(v));
endmodule
