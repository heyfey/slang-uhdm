// § caLvTrailIdxNamesByPath264
module top #(parameter int M = 1, parameter int P = 1) (input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  case (M)
    1: begin : c1
      assign w.en[P] = a[0];
    end
    default: begin : cd
      assign w.en[0] = a[0];
    end
  endcase
  assign w.en[3:2] = a[3:2];
  assign w.en[0] = a[1];
  assign o = w.en;
endmodule
